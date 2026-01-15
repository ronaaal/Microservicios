<?php

namespace App\Http\Controllers;

use App\Services\ReviewService;
use App\Services\BookService; // <-- IMPORTANTE: Necesitamos validar el libro también aquí
use App\Traits\ApiResponser;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ReviewController extends Controller
{
    use ApiResponser;

    public $reviewService;
    public $bookService;

    public function __construct(ReviewService $reviewService, BookService $bookService)
    {
        $this->reviewService = $reviewService;
        $this->bookService = $bookService;
    }

    public function index()
    {
        return $this->successResponse($this->reviewService->obtainReviews());
    }

    public function store(Request $request)
    {
        // Validamos que el libro exista ANTES de enviar la petición al microservicio
        // Esto es doble seguridad (Gateway y Microservicio)
        if ($request->has('book_id')) {
            $this->bookService->obtainBook($request->book_id);
        }
        
        return $this->successResponse(
            $this->reviewService->createReview($request->all()), 
            Response::HTTP_CREATED
        );
    }
}