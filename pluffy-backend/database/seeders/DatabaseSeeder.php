<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::create([
            'id' => 1,
            'name' => 'Roid Taqi',
            'email' => 'roidtaqi@pluffy.cafe',
            'password' => bcrypt('password123'),
            'loyalty_points' => 350,
            'loyalty_stamps' => 4,
            'membership_tier' => 'Gold Member',
        ]);

        $this->call([
            ProductSeeder::class,
        ]);
    }
}
