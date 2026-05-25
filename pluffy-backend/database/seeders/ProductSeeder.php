<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use App\Models\Product;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Product::create([
            'name' => 'Pluffy Cloud Soufflé',
            'description' => 'Award-winning signature soufflé pancake, extremely soft and served with premium whipped butter and snow sugar.',
            'base_price' => 45000,
            'category' => 'Soufflé',
            'image_url' => null,
            'rating' => 4.9,
            'availability_status' => 'available',
            'stock' => 12,
            'is_best_seller' => true,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Strawberry Cream Soufflé',
            'description' => 'Fluffy soufflé pancakes topped with organic fresh strawberry chunks and our light signature fresh cream.',
            'base_price' => 52000,
            'category' => 'Soufflé',
            'image_url' => null,
            'rating' => 4.8,
            'availability_status' => 'available',
            'stock' => 5,
            'is_best_seller' => true,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Butter Cream Croissant',
            'description' => 'Flaky, buttery French croissant baked fresh daily, layered with premium local honey butter spread.',
            'base_price' => 28000,
            'category' => 'Pastry',
            'image_url' => null,
            'rating' => 4.7,
            'availability_status' => 'sold_out',
            'stock' => 0,
            'is_best_seller' => false,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Pluffy Cloud Latte',
            'description' => 'Double shot espresso combined with fresh dairy milk and topped with our signature sweet cloud cold foam.',
            'base_price' => 32000,
            'category' => 'Coffee',
            'image_url' => null,
            'rating' => 4.8,
            'availability_status' => 'available',
            'stock' => 15,
            'is_best_seller' => true,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Iced Burgundy Latte',
            'description' => 'Smooth cold brew infused with organic dark cherry syrup and creamy milk, served over ice.',
            'base_price' => 35000,
            'category' => 'Coffee',
            'image_url' => null,
            'rating' => 4.6,
            'availability_status' => 'available',
            'stock' => 8,
            'is_best_seller' => false,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Peach Cream Tea',
            'description' => 'Refreshing black tea brewed with sweet peach nectar and finished with house matcha cold foam.',
            'base_price' => 29000,
            'category' => 'Non-Coffee',
            'image_url' => null,
            'rating' => 4.5,
            'availability_status' => 'available',
            'stock' => 4,
            'is_best_seller' => false,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Product::create([
            'name' => 'Seasonal Berry Fizz',
            'description' => 'Sparkling summer seasonal soda infused with crushed organic blueberries, raspberries, and fresh lime slices.',
            'base_price' => 34000,
            'category' => 'Seasonal',
            'image_url' => null,
            'rating' => 4.9,
            'availability_status' => 'available',
            'stock' => 2,
            'is_best_seller' => true,
            'is_seasonal' => true,
            'is_active' => true,
        ]);
    }
}
