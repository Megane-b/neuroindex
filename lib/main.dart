import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NeuroIndexApp());
}

class NeuroIndexApp extends StatelessWidget {
  const NeuroIndexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuroIndex',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class LinkItem {
  final String name;
  final String logoPath;
  final String description;
  final String url;
  final double logoScale;

  const LinkItem({
    required this.name,
    required this.logoPath,
    required this.description,
    required this.url,
    this.logoScale = 1.0,
  });
}

class FullWidthLinkButton extends StatelessWidget {
  final LinkItem item;

  const FullWidthLinkButton({super.key, required this.item});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLogo() {
    if (item.logoPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        item.logoPath,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      item.logoPath,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openUrl(item.url),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 55,
                  height: 55,
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Transform.scale(
                        scale: item.logoScale,
                        child: _buildLogo(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- FOND COMMUN (image + voile sombre), réutilisé sur toutes les pages ----------
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/logos/background.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.35),
          ),
        ),
        child,
        // Mention de la source de l'image, en bas de l'écran
        Positioned(
          bottom: 6,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Text(
              "Image: SONIC Team, INT (M. Racchini)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- ACCUEIL ----------
class LinkListPage extends StatelessWidget {
  final String title;
  final List<LinkItem> items;

  const LinkListPage({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // flèche de retour blanche
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return FullWidthLinkButton(item: items[index]);
            },
          ),
        ),
      ),
    );
  }
}

/// ---------- LISTE DE TOUS LES PROFESSIONNELS (ORDRE ALPHABETIQUE) ----------
class ProfessionalsListPage extends StatelessWidget {
  const ProfessionalsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "List of professionals",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // flèche de retour blanche
      ),
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('professionals')
                .orderBy('Name')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No professionals found.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        data['Name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${data['Lab']} • ${data['position']} • ${data['HDR']} \n${data['mail']} \n${data['key words']}",
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ---------- LABORATOIRES ----------
final List<LinkItem> laboratories = [
  LinkItem(
    name: "INMED",
    logoPath: "assets/logos/inmed.png",
    description: "Institute of Neurobiology of the Mediterranean Sea, research on the development and pathologies of the nervous system.",
    url: "https://www.inmed.fr",
    logoScale: 1.4,
  ),
  LinkItem(
    name: "IBDM",
    logoPath: "assets/logos/ibdm.png",
    description: "Institute of Developmental Biology of Marseille, developmental biology and neuroscience.",
    url: "https://www.ibdm.univ-amu.fr",
    logoScale: 1.6,
  ),
  LinkItem(
    name: "CRPN",
    logoPath: "assets/logos/crpn.png",
    description: "Research Center in Psychology and Neuroscience, study of the neural basis of behavior and cognition.",
    url: "https://crpn.univ-amu.fr/fr",
    logoScale: 1.1,
  ),
  LinkItem(
    name: "CRMBM",
    logoPath: "assets/logos/crmbm.png",
    description: "Center for Magnetic Resonance in Biology and Medicine, MRI applied to biomedical research.",
    url: "https://crmbm.univ-amu.fr/",
    logoScale: 1.0,
  ),
  LinkItem(
    name: "INT",
    logoPath: "assets/logos/int.jpg",
    description: "Institute of Neuroscience of Timone, cognitive and systems neuroscience.",
    url: "https://www.int.univ-amu.fr/",
    logoScale: 1.4,
  ),
  LinkItem(
    name: "INS",
    logoPath: "assets/logos/ins.png",
    description: "Institute of Systems Neuroscience, study of neural networks in health and disease.",
    url: "https://ins-amu.fr/",
    logoScale: 1.1,
  ),
  LinkItem(
    name: "INP",
    logoPath: "assets/logos/inp.png",
    description: "Institute of Neurophysiopathology, physiopathological mechanisms of nervous system diseases.",
    url: "https://inp.univ-amu.fr/fr",
    logoScale: 1.4,
  ),
  LinkItem(
    name: "MMG",
    logoPath: "assets/logos/mmg.png",
    description: "Marseille Medical Genetics, human genetics and rare diseases, including neurodevelopmental disorders.",
    url: "https://www.marseille-medical-genetics.org/fr/",
    logoScale: 1.3,
  ),
  LinkItem(
    name: "ISM",
    logoPath: "assets/logos/ism.png",
    description: "Institute of Movement Sciences, motor control, biomechanics and movement neuroscience.",
    url: "https://ism.univ-amu.fr/fr",
    logoScale: 1.4,
  ),
  LinkItem(
    name: "LPL",
    logoPath: "assets/logos/lpl.jpg",
    description: "Laboratory of Speech and Language, study of language, speech and cognition.",
    url: "https://lpl-aix.fr/fr",
    logoScale: 1.1,
  ),
  LinkItem(
    name: "CRVM",
    logoPath: "assets/logos/crvm.webp",
    description: "Research center focused on vision and movement (to be refined with the exact scope of the center).",
    url: "https://www.crvm.eu/",
    logoScale: 1.3,
  ),
  LinkItem(
    name: "PSYCLE",
    logoPath: "assets/logos/psycle.png",
    description: "Laboratory of Clinical Psychology, Psychopathology and Psychoanalysis, research in clinical psychology.",
    url: "https://centrepsycle-amu.fr/",
    logoScale: 1.1,
  ),
];

/// ---------- LIENS UTILES ----------
final List<LinkItem> usefulLinks = [
  LinkItem(
    name: "NeuroSchool",
    logoPath: "assets/logos/neuroschool2.png",
    description: "Graduate research school in neuroscience at Aix-Marseille University, bringing together training programs and partner laboratories.",
    url: "https://neuro-marseille.org/en/",
    logoScale: 1.2,
  ),
  LinkItem(
    name: "ILCB",
    logoPath: "assets/logos/ilcb2.png",
    description: "Institute of Language Communication and the Brain, dedicated to the science of language and communication.",
    url: "https://www.ilcb.fr/",
    logoScale: 1.2,
  ),
    LinkItem(
    name: "Institut Laennec",
    logoPath: "assets/logos/laennec2.png",
    description: "The Institut Laënnec fosters interdisciplinary collaboration between medicine, digital sciences, AI, law, and ethics to translate cutting-edge digital and AI innovations into concrete improvements in patient care.",
    url: "https://institut-laennec.univ-amu.fr/en/node/88",
    logoScale: 1.3,
  ),
  LinkItem(
    name: "Institut Imaging",
    logoPath: "assets/logos/imaging.png",
    description: "Institute dedicated to biomedical imaging and imaging technologies applied to research.",
    url: "https://institut-imaging.univ-amu.fr/en/node/88",
    logoScale: 1.4,
  ),
  LinkItem(
    name: "Master Neuroscience AMU",
    logoPath: "assets/logos/master_neuro.png",
    description: "Master's degree in Neuroscience at Aix-Marseille University, academic training in brain sciences.",
    url: "https://sciences.univ-amu.fr/en/study-program/master-degree/neurosciences",
    logoScale: 1.2,
  ),
  LinkItem(
    name: "Licence 3 Neuroscience AMU",
    logoPath: "assets/logos/licence3_neuro.png",
    description: "Bachelor's degree in Life Sciences (Neuroscience track) at Aix-Marseille University, combining theoretical and practical training in neuroscience, biology, statistics, and experimental methods.",
    url: "https://sciences.univ-amu.fr/en/study-program/bachelor-degree/neurosciences",
    logoScale: 1.2,
  ),
  LinkItem(
    name: "Neuronautes",
    logoPath: "assets/logos/neuronautes.jpeg",
    description: "A student association in neuroscience that promotes scientific understanding and helps neuroscience students.",
    url: "https://linktr.ee/neuronautes",
    logoScale: 1.2,
  ),
  LinkItem(
    name: "SynapSciences",
    logoPath: "assets/logos/synapsciences.png",
    description: "A science outreach association focused on neuroscience and brain function (popularizing articles, debunking myths, exploring neuroscientific concepts)",
    url: "https://synapsciences.github.io/",
    logoScale: 2.5,
  ),
];

/// ---------- PAGE D'ACCUEIL ----------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // l'image passe aussi derrière l'AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0, // supprime l'espace réservé par défaut autour du titre
        title: Container(
          width: double.infinity, // la bande prend presque toute la largeur
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logos/neuroindex.svg',
                height: 40,
              ),
              const SizedBox(width: 12),
              const Text(
                "NeuroIndex",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  const Center(
                    child: Text(
                      "The Guide to Neuroscience Professionals at Aix-Marseille University (AMU).\n\n"
                      "This directory aims to list professionals working in neuroscience research at AMU, "
                      "including their research laboratory, position, email address, and key information about their research (techniques, topics, etc.).\n"
                      "If the individual is a principal investigator (PI), their accreditation to supervise research (HDR) is indicated. "
                      "Finally, if the PI holds an HDR, the number of PhD students they are currently supervising may be listed.\n",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.science_outlined, size: 28),
                      label: const Text(
                        "Laboratories",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LinkListPage(
                              title: "Laboratories",
                              items: laboratories,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.link, size: 28),
                      label: const Text(
                        "Useful links",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LinkListPage(
                              title: "Useful links",
                              items: usefulLinks,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.people_outline, size: 28),
                      label: const Text(
                        "List of professionals",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfessionalsListPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "search (iPSC, Patch Clamp, name...)",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        query = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // IMPORTANT : ce ListView fait désormais partie du scroll global
                  // de la page (shrinkWrap + NeverScrollableScrollPhysics), donc on
                  // ne peut plus utiliser Expanded ici. La page entière défile
                  // d'un seul tenant, recherche incluse.
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('professionals').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      final q = query.toLowerCase();

                      final filtered = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['Name'] ?? '').toString().toLowerCase();
                        final lab = (data['Lab'] ?? '').toString().toLowerCase();
                        final keywords = (data['key words'] ?? '').toString().toLowerCase();
                        final position = (data['position'] ?? '').toString().toLowerCase();
                        final hdr = (data['HDR'] ?? '').toString().toLowerCase();
                        final skills = keywords.split(' ');

                        return name.contains(q) ||
                               lab.contains(q) ||
                               position.contains(q) ||
                               hdr.contains(q) ||
                               skills.any((s) => s.contains(q));
                      }).toList();

                      if (q.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Type a keyword to search for a researcher, a lab, or a technique.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final data = filtered[index].data() as Map<String, dynamic>;
                          return Card(
                            child: ListTile(
                              title: Text(data['Name'] ?? ''),
                              subtitle: Text(
                                "${data['Lab']} • ${data['position']} • ${data['HDR']} \n${data['mail']} \n${data['key words']}",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 80), // espace vide en bas, fond visible seul
                ],
              ),
            ),
          ),
        ),
      );
  }
}