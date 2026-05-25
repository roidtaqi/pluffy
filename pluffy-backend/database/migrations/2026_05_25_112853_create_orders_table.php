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
        Schema::create('orders', function (Blueprint $table) {
            $table->string('id')->primary(); // Format: ORD-XXXX-YY
            $table->unsignedBigInteger('user_id')->nullable();
            $table->integer('subtotal');
            $table->integer('discount');
            $table->integer('tax');
            $table->integer('service_fee');
            $table->integer('total');
            $table->string('status')->default('placed');
            $table->string('outlet_name');
            $table->string('payment_method');
            $table->string('voucher_code')->nullable();
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
