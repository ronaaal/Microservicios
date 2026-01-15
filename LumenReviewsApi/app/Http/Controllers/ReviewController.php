<?php

namespace App\Http\Controllers;

use App\Review;
use App\Traits\ApiResponser;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Services\BookService;

class ReviewController extends Controller
{
    use ApiResponser;

    /**
     * El servicio para consumir el servicio de libros
     * @var BookService
     */
    public $bookService;

    public function __construct(BookService $bookService)
    {
        $this->bookService = $bookService;
    }

    /**
     * Retorna la lista de reseñas
     */
    public function index()
    {
        $reviews = Review::all();
        return $this->successResponse($reviews);
    }

    /**
     * Crea una nueva reseña
     */
    public function store(Request $request)
    {
        // 1. Validar reglas de entrada
        $rules = [
            'comment' => 'required|max:255',
            'rating' => 'required|integer|min:1|max:5',
            'book_id' => 'required|integer|min:1',
        ];

        $this->validate($request, $rules);

        // 2. VALIDACIÓN CRUCIAL: Preguntar al servicio de Libros si existe
        // Si falla, el BookService lanzará una excepción y se detendrá aquí.
        $this->bookService->obtainBook($request->book_id);

        // 3. Si el libro existe, creamos la reseña
        $review = Review::create($request->all());

        return $this->successResponse($review, Response::HTTP_CREATED);
    }

    /**
     * Muestra una reseña específica
     */
    public function show($review)
    {
        $review = Review::findOrFail($review);
        return $this->successResponse($review);
    }

    /**
     * Actualiza una reseña existente
     */
    public function update(Request $request, $review)
    {
        $review = Review::findOrFail($review);

        // Si intenta cambiar el libro, verificamos que el nuevo exista
        if ($request->has('book_id')) {
            $this->bookService->obtainBook($request->book_id);
        }

        $review->fill($request->all());

        if ($review->isClean()) {
            return $this->errorResponse('Al menos un valor debe cambiar', Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $review->save();

        return $this->successResponse($review);
    }

    /**
     * Elimina una reseña
     */
    public function destroy($review)
    {
        $review = Review::findOrFail($review);
        $review->delete();

        return $this->successResponse($review);
    }
}