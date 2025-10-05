import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Fetch one Pokemon by ID from jsonplaceholder
Future<Pokemon> fetchPokemon(int id) async {
  // Build the request URL
  //final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/{id}');
  final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/${id}');

  // Perform GET request with a 180-second timeout
  final res = await http.get(uri).timeout(const Duration(seconds: 180));

  if (res.statusCode == 200) {
    // Parse the JSON body into a Dart map, then into an Pokemon object
    return Pokemon.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  } else {
    // If server response wasn’t 200, throw an exception
    throw Exception('Failed to load Pokemon (HTTP ${res.statusCode})');
  }
}

// Create a list of Pokemon
Future<List<Pokemon>> fetchAllPokemon(int max) async {
  final futures = <Future<Pokemon>>[];
  for (int i = 1; i <= max; i++) {
    futures.add(fetchPokemon(i));
  }
  return await Future.wait(futures);
}

/// Simple Dart model for an Pokemon record
class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final String? sprite;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    this.sprite,
  });

  factory Pokemon.fromJson(Map<String, dynamic> j) => Pokemon(
    id: j['id'] as int,
    name: j['name'] as String,
    height: j['height'] as int,
    weight: j['weight'] as int,
    types: (j['types'] as List)
        .map((t) => (t['type']['name'] as String))
        .toList(),
    sprite: (j['sprites']?['front_default']) as String?,
    //Line used for testing
    //sprite: ((j['sprites']?['front_default']) as String?)! +'_break',
  );
}

void main() {
  runApp(const Pokedex());
}

class Pokedex extends StatelessWidget {
  const Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    //Set Theme and Title
    return MaterialApp(
      title: 'Pokedex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MyHomePage(title: 'Pokedex'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //Constructor and Initalizers
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Pokemon>> _allPokemon;

  //Constructor
  @override
  void initState() {
    super.initState();
    _allPokemon = fetchAllPokemon(151);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Build App Bar
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      //Build Main Body
      body: FutureBuilder<List<Pokemon>>(
        future: _allPokemon,
        builder: (context, snapshot) {
          //While connecting, show loading wheel
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
            //If error, load error and have a retry button
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load Pokémon'),
                  Text(snapshot.error.toString()),
                  //Retry button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _allPokemon = fetchAllPokemon(151);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
            //If successful build Pokedex
          } else if (snapshot.hasData) {
            final pokemons = snapshot.data!;
            return SafeArea(
              //Adds pull down to refresh
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _allPokemon = fetchAllPokemon(151);
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      //Adds instruction and refresh button
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            //Direction
                            child: Text(
                              'Select the Pokémon you would like to learn more about:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          //Refresh button
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _allPokemon = fetchAllPokemon(151);
                              });
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.black,
                            ),
                            tooltip: 'Refresh Pokémon',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      //Gridview builder
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              //5 cards per row & grid formatting
                              crossAxisCount: 5,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: pokemons.length,
                        //Build per pokemon in list
                        itemBuilder: (context, index) {
                          final pokemon = pokemons[index];
                          //Recognize if card is pressed
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                //If pressed show Detail Dialog
                                builder: (_) =>
                                    PokemonInfoDialog(pokemon: pokemon),
                              );
                            },
                            //Build Card
                            child: Card(
                              //Card formatting
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  //Display some API contents on card (ex. #ID and Sprite)
                                  children: [
                                    Text(
                                      '#${pokemon.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    //Display Image if there is one
                                    if (pokemon.sprite != null)
                                      Expanded(
                                        child: Image.network(
                                          pokemon.sprite!,
                                          fit: BoxFit.contain,
                                          //If there is an issue, display broken image icon
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.broken_image),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
            //If no data returned
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}

//Dialog box that contains additinal Pokemon information that appears when Card is pressed
class PokemonInfoDialog extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonInfoDialog({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      //Dialog formatting
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          //Dialog Constraint - Don't want it to big
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(16),
          //Scrollable if needed
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Close Dialog
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Add Sprite if there is one
                if (pokemon.sprite != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 180,
                      width: 180,
                      //Get Sprite
                      child: Image.network(
                        pokemon.sprite!,
                        fit: BoxFit.contain,
                        //If there is an issue, display broken image icon
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Print and Format Name
                Text(
                  pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                //Print and Format ID
                Text(
                  'Pokedex No. ${pokemon.id}',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 12),

                //Print and Format pokemon types
                Text(
                  'Type: ${pokemon.types.map((t) => t[0].toUpperCase() + t.substring(1)).join(', ')}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                //Print and Format pokemon height and weight (convert to cm and kg)
                Text('Height: ${pokemon.height * 10} cm'),
                Text('Weight: ${(pokemon.weight / 10).toStringAsFixed(1)} kg'),

                const SizedBox(height: 16),

                //Close Dialog button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
