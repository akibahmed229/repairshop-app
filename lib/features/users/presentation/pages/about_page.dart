import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Optional: for X/LinkedIn icons
import 'package:url_launcher/url_launcher.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class AboutPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const AboutPage());
  const AboutPage({super.key});

  // Helper function to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- APP SECTION ---
            const Icon(
              Icons.build_circle_rounded,
              size: 80,
              color: AppPallete.gradient1,
            ),
            const SizedBox(height: 16),
            const Text(
              'RepairShop App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text(
              'A comprehensive solution for technical note management and repair tracking. '
              'Streamline your workshop workflow with real-time status updates and team collaboration.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 40),

            // --- DEVELOPER CARD ---
            const Text(
              'Developed By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppPallete.borderColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppPallete.borderColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blueAccent,
                    child: Image.asset(
                      'assets/images/Ahmed-logo.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Akib Ahmed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ahmed15-5827@diu.edu.bd',
                    style: TextStyle(
                      color: Colors.blueAccent[100],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SOCIAL ICONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        FontAwesomeIcons.github,
                        'https://github.com/akibahmed229',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.linkedin,
                        'https://linkedin.com/in/akibahmed229',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.facebook,
                        'https://www.facebook.com/AhmedAkib229',
                      ),
                      _socialIcon(
                        FontAwesomeIcons.xTwitter,
                        'https://x.com/ahmedakib229',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return IconButton(
      onPressed: () => _launchURL(url),
      icon: FaIcon(icon, size: 22),
      color: Colors.grey[400],
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
