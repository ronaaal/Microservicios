<?php

namespace App\Traits;

use GuzzleHttp\Client;

trait ConsumesExternalService
{
    /**
     * Send a request to any service
     * @param string $method HTTP method (GET, POST, PUT, DELETE, etc.)
     * @param string $requestUrl The endpoint URL
     * @param array $formParams Form parameters for POST/PUT requests
     * @param array $headers Additional headers
     * @return array Decoded JSON response
     */
    public function performRequest($method, $requestUrl, $formParams = [], $headers = [])
    {
        // Validate baseUri is set
        if (empty($this->baseUri)) {
            throw new \RuntimeException('Base URI is not configured. Please check your .env file and ensure AUTHORS_SERVICE_BASE_URL and BOOKS_SERVICE_BASE_URL are set.');
        }

        // Prevent Gateway from calling itself
        if (strpos($this->baseUri, 'localhost:8000') !== false || strpos($this->baseUri, '127.0.0.1:8000') !== false) {
            throw new \RuntimeException('ERROR: Base URI is pointing to the Gateway itself (port 8000). It should point to the microservices (8001 for Authors, 8002 for Books). Check your .env file.');
        }

        $client = new Client([
            'base_uri' => $this->baseUri,
            'timeout' => 10.0,
            'http_errors' => true,
        ]);

        if (isset($this->secret)) {
            $headers['Authorization'] = $this->secret;
        }

        // Use json for JSON requests, form_params for form data
        $options = ['headers' => $headers];
        
        if (!empty($formParams)) {
            if (in_array(strtoupper($method), ['GET', 'DELETE'])) {
                // For GET/DELETE, use query parameters
                $options['query'] = $formParams;
            } else {
                // For POST/PUT/PATCH, use JSON body
                $options['json'] = $formParams;
            }
        }

        try {
            $response = $client->request($method, $requestUrl, $options);
            
            $body = $response->getBody()->getContents();
            
            // Decode JSON response
            $decoded = json_decode($body, true);
            
            // If the response already has a 'data' key (from microservice response),
            // extract it so the Gateway can wrap it again properly
            if (json_last_error() === JSON_ERROR_NONE) {
                if (isset($decoded['data']) && is_array($decoded) && count($decoded) === 1) {
                    // Response is wrapped in 'data', extract it
                    return $decoded['data'];
                }
                // Return decoded data as-is
                return $decoded;
            }
            
            // If JSON decode failed, return raw body
            return $body;
        } catch (\GuzzleHttp\Exception\ConnectException $e) {
            // Connection timeout or refused
            $message = $e->getMessage();
            if (strpos($message, 'localhost:8000') !== false) {
                throw new \RuntimeException(
                    'ERROR: El Gateway está intentando conectarse a sí mismo. ' .
                    'Verifica que AUTHORS_SERVICE_BASE_URL=http://localhost:8001 y ' .
                    'BOOKS_SERVICE_BASE_URL=http://localhost:8002 en tu archivo .env'
                );
            }
            throw new \RuntimeException('No se pudo conectar al microservicio: ' . $this->baseUri . '. Error: ' . $message);
        } catch (\GuzzleHttp\Exception\ClientException $e) {
            // Re-throw client exceptions so they can be handled by the exception handler
            throw $e;
        } catch (\Exception $e) {
            // For other exceptions, re-throw
            throw $e;
        }
    }
}
