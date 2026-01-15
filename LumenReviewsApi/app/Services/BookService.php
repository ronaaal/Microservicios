<?php

namespace App\Services;

use App\Traits\ConsumesExternalService;

class BookService
{
    use ConsumesExternalService;

    public $baseUri;
    public $secret;

    public function __construct()
    {
        $this->baseUri = env('BOOKS_SERVICE_BASE_URL');
        $this->secret = env('BOOKS_SERVICE_SECRET');
    }

    public function obtainBook($book)
    {
        return $this->performRequest('GET', "/books/{$book}");
    }
}