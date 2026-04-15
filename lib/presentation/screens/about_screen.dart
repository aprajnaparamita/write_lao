import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Author photo
            ClipOval(
              child: Image.asset(
                'assets/images/janet.JPG',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // App name and version
            Text(
              'Write Lao',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'by Janet Jeffus',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Copyright \u00A9 2026',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 32),

            // Story
            Text(
              'After more than twenty years as a software engineer, I found '
              'myself wanting to learn Lao \u2014 specifically, how to read and '
              'write the beautiful Lao script. I went looking for an app that '
              'would teach me the characters stroke by stroke, the way you '
              'might learn to write them in a classroom. I couldn\'t find one.\n\n'
              'So I decided to build it myself.\n\n'
              'Write Lao guides you through every consonant, vowel, and tone '
              'mark in the Lao alphabet. Each character is broken down into '
              'individual strokes with the correct order and direction. You '
              'trace each stroke on screen, and the app tells you whether '
              'you got it right \u2014 no guessing, no flashcards, just '
              'practice.\n\n'
              'I hope this app helps you on your own journey with the Lao '
              'language. Happy writing!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                child: const Text('Done'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
