<?php

use Laravel\Lumen\Testing\DatabaseMigrations;
use Laravel\Lumen\Testing\DatabaseTransactions;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     *
     * @return void
     */
    public function testExample()
    {
        // Test básico: verificar que la aplicación se puede instanciar
        $this->assertNotNull($this->app);
        $this->assertInstanceOf(\Laravel\Lumen\Application::class, $this->app);
    }
}
