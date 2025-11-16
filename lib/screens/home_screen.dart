import 'package:flutter/material.dart';
import 'package:defensa_del_muro/screens/level_select_screen.dart';
import 'package:defensa_del_muro/screens/settings_screen.dart'; // New import for settings screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondos/fondo_home.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Game Title
                Expanded(
                  child: Center(
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Medieval',
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withAlpha((255 * 0.8).round()),
                            offset: const Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Menu Buttons
                _MenuButton(
                  imagePath: 'assets/botones/PlayButton.gif',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LevelSelectScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/TiendaButton.gif',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/BestiarioButton.gif',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  imagePath: 'assets/botones/ScoreboardButton.gif',
                  onPressed: () {
                    // TODO: Implement navigation to Scoreboard screen
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          // Hamburger Menu Icon
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Image.asset(
                'assets/botones/New Piskel.png',
                width: 40,
                height: 40,
              ),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/fondos/fondo_ajustes.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 80, // Adjust height as needed
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.brown.shade900.withAlpha(
                    (255 * 0.7).round(),
                  ), // Darker, semi-transparent background
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Menú',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: 'Medieval', // Apply medieval font
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.login,
                  color: Colors.white,
                ), // White icon
                title: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Medieval',
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Inicio de sesión'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              const TextField(
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                ),
                              ),
                              const SizedBox(height: 10),
                              const TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Google Sign-In
                                },
                                child: const Text('Iniciar sesión con Google'),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cerrar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ), // White icon
                title: const Text(
                  'Ajustes',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Medieval',
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _MenuButton({required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        imagePath, // Adjust width as needed
        height: 70, // Adjust height as needed
        fit: BoxFit.contain,
      ),
    );
  }
}
