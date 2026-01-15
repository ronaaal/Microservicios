<?php

namespace App\Services;

use App\Traits\ConsumesExternalService;

class ReviewService
{
    use ConsumesExternalService;

    public $baseUri;
    public $secret;

    public function __construct()
    {
        $this->baseUri = config('services.reviews.base_uri');
        $this->secret = config('services.reviews.secret');
    }

    /**
     * Obtener todas las reseñas
     */
    public function obtainReviews()
    {
        return $this->performRequest('GET', '/reviews');
    }

    /**
     * Crear una reseña
     */
    public function createReview($data)
    {
        return $this->performRequest('POST', '/reviews', $data);
    }
}