<?php



     return array(
         "paths" => array(
             "migrations" => getenv('PATH')
         ),
         "environments" => array(
             "default_migration_table" => "phinxlog",
             "default_database" => "dev",
             "dev" => array(
                 "adapter" => "mysql",
                 "host" => getenv('DB_HOST'),
                 "name" => getenv('DB_NAME'),
                 "user" => getenv('DB_USER'),
                 "pass" => getenv('DB_PASS'),
                 "port" => getenv('DB_PORT')
             )
         )
     );
