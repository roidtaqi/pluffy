<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->integer('base_price');
            $table->string('category');
            $table->string('image_url')->nullable();
            $table->decimal('rating', 2, 1)->nullable();
            $table->string('availability_status')->default('available');
            $table->integer('stock')->default(10);
            $table->boolean('is_best_seller')->default(false);
            $table->boolean('is_seasonal')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
