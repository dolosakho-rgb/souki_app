import 'package:flutter/material.dart';

void main() {
	  runApp(const MyApp());
	  }

	  class MyApp extends StatelessWidget {
	  	  const MyApp({super.key});

	  	    @override
	  	      Widget build(BuildContext context) {
	  	      	    return MaterialApp(
	  	      	    	      title: 'Souki App',
	  	      	    	            debugShowCheckedModeBanner: false,
	  	      	    	                  theme: ThemeData(
	  	      	    	                  	        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
	  	      	    	                  	                useMaterial3: true,
	  	      	    	                  	                      ),
	  	      	    	                  	                            home: const HomeScreen(),
	  	      	    	                  	                                );
	  	      	    	                  	                                  }
	  	      	    	                  	                                  }

	  	      	    	                  	                                  class HomeScreen extends StatelessWidget {
	  	      	    	                  	                                  	  const HomeScreen({super.key});

	  	      	    	                  	                                  	    @override
	  	      	    	                  	                                  	      Widget build(BuildContext context) {
	  	      	    	                  	                                  	      	    return Scaffold(
	  	      	    	                  	                                  	      	    	      appBar: AppBar(
	  	      	    	                  	                                  	      	    	      	        title: const Text('Souki App'),
	  	      	    	                  	                                  	      	    	      	                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
	  	      	    	                  	                                  	      	    	      	                      ),
	  	      	    	                  	                                  	      	    	      	                            body: const Center(
	  	      	    	                  	                                  	      	    	      	                            	        child: Text(
	  	      	    	                  	                                  	      	    	      	                            	        	          'Bienvenue sur Souki App !',
	  	      	    	                  	                                  	      	    	      	                            	        	                    style: TextStyle(fontSize: 20),
	  	      	    	                  	                                  	      	    	      	                            	        	                            ),
	  	      	    	                  	                                  	      	    	      	                            	        	                                  ),
	  	      	    	                  	                                  	      	    	      	                            	        	                                      );
	  	      	    	                  	                                  	      	    	      	                            	        	                                        }
	  	      	    	                  	                                  	      	    	      	                            	        	                                        }

	  	      	    	                  	                                  	      	    	      	                            	        	                                        s
	  	      	    	                  	                                  	      	    	      	                            	        	                                       
	  	      	    	                  	                                  	      	    	      	                            	        )
	  	      	    	                  	                                  	      	    	      	                            )
	  	      	    	                  	                                  	      	    	      )
	  	      	    	                  	                                  	      	    )
	  	      	    	                  	                                  	      }
	  	      	    	                  	                                  }
	  	      	    	                  )
	  	      	    )
	  	      }
	  }
}
