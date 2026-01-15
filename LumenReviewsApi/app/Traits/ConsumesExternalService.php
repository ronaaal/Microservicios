<?php

namespace App\Traits;

use GuzzleHttp\Client;

trait ConsumesExternalService
{
    /**
     * Enviar una petición a un servicio externo
     */
    public function performRequest($method, $requestUrl, $formParams = [], $headers = [])
    {
        // Crear el cliente HTTP (Guzzle)
        $client = new Client([
            'base_uri' => $this->baseUri,
            'timeout'  => 5.0, // Esperar máx 5 segundos
        ]);

        // Si tenemos un secreto (seguridad), lo enviamos
        if (isset($this->secret)) {
            $headers['Authorization'] = $this->secret;
        }

        // Preparar la petición
        $options = ['headers' => $headers];

        if (isset($formParams)) {
            if (strtoupper($method) == 'GET') {
                $options['query'] = $formParams;
            } else {
                $options['form_params'] = $formParams;
            }
        }

        // Ejecutar la petición y devolver la respuesta
        $response = $client->request($method, $requestUrl, $options);

        return $response->getBody()->getContents();
    }
}