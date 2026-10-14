import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const CareerKitApp());

const ink = Color(0xFF1F2933);
const accent = Color(0xFF0F766E);

class CareerKitApp extends StatelessWidget {
  const CareerKitApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Career kit (prototype)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: accent),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F5F2),
        ),
        home: const Shell(),
      );
}

// ---------- state (in memory only, demo) ----------
enum Prov { self, attested, issuer }

String provLabel(Prov p) => switch (p) {
      Prov.self => 'Self-described',
      Prov.attested => 'Supervisor-attested (demo)',
      Prov.issuer => 'Issuer-verified',
    };

class Claim {
  final String text;
  Prov prov;
  Claim(this.text, this.prov);
}

class Cred {
  final String name, level, issuer;
  final bool verified;
  const Cred(this.name, this.level, this.issuer, this.verified);
}

class AppState extends ChangeNotifier {
  String trade = 'Electrician';
  int years = 3;
  bool showPhone = false, showEmail = true, showClaims = true, showCreds = true;
  bool openToWork = false;
  final claims = <Claim>[
    Claim('Pulled and terminated branch circuits', Prov.attested),
    Claim('Read electrical plans', Prov.self),
  ];
  final creds = const [
    Cred('Core Curriculum', 'Demo credential', 'Demo issuer', true),
    Cred('Electrical Level 1', 'Demo credential', 'Demo issuer', true),
    Cred('OSHA 10 card', 'Demo credential', 'Self-added, not verified', false),
  ];
  final tasksByTrade = const {
    'Electrician': ['Pulled and terminated branch circuits', 'Bent conduit', 'Installed panels', 'Read electrical plans', 'Tested circuits', 'Troubleshot faults'],
    'Carpenter': ['Framed walls', 'Set forms', 'Hung doors', 'Read plans', 'Installed trim'],
    'Welder': ['Stick welding', 'MIG welding', 'Read weld symbols', 'Fit-up and tack', 'Inspected welds'],
    'Plumber': ['Roughed in drain lines', 'Soldered copper', 'Set fixtures', 'Pressure tested lines'],
  };
  final checklist = <String, bool>{
    'Upload OSHA 10 card': false,
    'Add site safety orientation date': false,
    'Confirm PPE list with foreman': false,
    'Save the site contact in your phone': false,
  };
  bool codeLinked = false;
  void changed() => notifyListeners();
  String get headline => '$trade, $years years';
}

final state = AppState();

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[ProfilePage(), PathPage(), KitPage(), FundingPage(), NewJobPage()];
    return ListenableBuilder(
      listenable: state,
      builder: (c, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Career kit'),
          backgroundColor: const Color(0xFFF7F5F2),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(label: const Text('Prototype, demo data'), visualDensity: VisualDensity.compact, backgroundColor: Colors.amber.shade100),
            )
          ],
        ),
        body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: pages[tab]))),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.badge_outlined), label: 'Profile'),
            NavigationDestination(icon: Icon(Icons.stairs_outlined), label: 'Path'),
            NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Job change'),
            NavigationDestination(icon: Icon(Icons.savings_outlined), label: 'Funding'),
            NavigationDestination(icon: Icon(Icons.checklist), label: 'New job'),
          ],
        ),
      ),
    );
  }
}

// ---------- shared bits ----------
Widget h(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink)));
Widget note(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(color: Color(0xFF52606D), height: 1.4)));

class ProvChip extends StatelessWidget {
  final Prov p;
  const ProvChip(this.p, {super.key});
  @override
  Widget build(BuildContext context) {
    final col = switch (p) { Prov.self => Colors.grey.shade700, Prov.attested => Colors.blue.shade700, Prov.issuer => accent };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: col), borderRadius: BorderRadius.circular(12)),
      child: Text(provLabel(p), style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w600)),
    );
  }
}

void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));
Future<void> open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

// ---------- Profile: headline, task record, contact route, crew attestation ----------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Marcus (fictional demo worker)', style: TextStyle(fontSize: 12, color: Colors.black54)),
            Text(state.headline, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 4),
            Text('${state.claims.length} tasks on record, ${state.creds.where((c) => c.verified).length} verified credentials'),
            const SizedBox(height: 12),
            Row(children: [
              DropdownButton<String>(
                value: state.trade,
                items: [for (final t in state.tasksByTrade.keys) DropdownMenuItem(value: t, child: Text(t))],
                onChanged: (v) {
                  state.trade = v!;
                  state.claims.clear();
                  state.changed();
                },
              ),
              const SizedBox(width: 16),
              IconButton(onPressed: () { if (state.years > 0) { state.years--; state.changed(); } }, icon: const Icon(Icons.remove_circle_outline)),
              Text('${state.years} yrs'),
              IconButton(onPressed: () { state.years++; state.changed(); }, icon: const Icon(Icons.add_circle_outline)),
            ]),
          ]),
        ),
      ),
      h('Task record'),
      note('Tap what you have done. Tap again to remove. Each one is labelled self-described until someone confirms it. Nothing here is a certification.'),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final t in state.tasksByTrade[state.trade]!)
          FilterChip(
            label: Text(t),
            selected: state.claims.any((c) => c.text == t),
            onSelected: (on) {
              if (on) {
                state.claims.add(Claim(t, Prov.self));
              } else {
                state.claims.removeWhere((c) => c.text == t);
              }
              state.changed();
            },
          ),
      ]),
      const SizedBox(height: 8),
      for (final c in state.claims)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(c.text),
          subtitle: Align(alignment: Alignment.centerLeft, child: ProvChip(c.prov)),
          trailing: c.prov == Prov.self
              ? TextButton(onPressed: () => askSupervisor(context, c), child: const Text('Ask supervisor'))
              : null,
        ),
      h('Credentials'),
      note('Demo credentials. In a real product, verified would mean the issuer confirmed it. Tasks are never issuer-verified here: only a supervisor can confirm a task, and in this demo that is simulated.'),
      for (final c in state.creds)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(c.verified ? Icons.verified : Icons.help_outline, color: c.verified ? accent : Colors.grey),
          title: Text(c.name),
          subtitle: Text(c.issuer),
        ),
      h('What a foreman sees when you share'),
      note('You choose each field. The phone number can stay hidden; people reach you through a message button.'),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Phone number'), value: state.showPhone, onChanged: (v) { state.showPhone = v; state.changed(); }),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Email'), value: state.showEmail, onChanged: (v) { state.showEmail = v; state.changed(); }),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Task record'), value: state.showClaims, onChanged: (v) { state.showClaims = v; state.changed(); }),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Credentials'), value: state.showCreds, onChanged: (v) { state.showCreds = v; state.changed(); }),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => showSharedView(context), icon: const Icon(Icons.visibility_outlined), label: const Text('Preview shared profile')),
      const SizedBox(height: 24),
    ]);
  }

  void askSupervisor(BuildContext context, Claim c) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ask a supervisor to confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('"${c.text}"'),
          const SizedBox(height: 8),
          note('They would get one link. They see only this task and your name, can decline, and you can revoke it. In this prototype nothing is sent.'),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              c.prov = Prov.attested;
              state.changed();
              snack(context, 'Demo only: marked as attested. A real request would wait for the supervisor.');
            },
            child: const Text('Simulate supervisor confirming'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ]),
      ),
    );
  }

  void showSharedView(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => SharedView());
  }
}

class SharedView extends StatelessWidget {
  SharedView({super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Shared profile (what they see)', style: TextStyle(fontSize: 12, color: Colors.black54)),
          Text(state.headline, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          if (state.openToWork) const Padding(padding: EdgeInsets.only(top: 4), child: Text('Open to work', style: TextStyle(color: accent, fontWeight: FontWeight.w600))),
          if (state.showPhone) const Text('Phone: 555-0100 (demo)'),
          if (state.showEmail) const Text('Email: marcus@example.com (demo)'),
          if (!state.showPhone) OutlinedButton(onPressed: null, child: const Text('Message Marcus')),
          if (state.showClaims) ...[h('Tasks'), for (final c in state.claims) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Expanded(child: Text(c.text)), ProvChip(c.prov)]))],
          if (state.showCreds) ...[h('Credentials'), for (final c in state.creds) Text('${c.verified ? "Verified (demo)" : "Not verified"}: ${c.name}')],
        ]),
      );
}

// ---------- Path: pathway view + gap-triggered learning ----------
class PathPage extends StatelessWidget {
  const PathPage({super.key});
  @override
  Widget build(BuildContext context) {
    const levels = [
      ['Core', 'Done', true],
      ['Level 1', 'Done', true],
      ['Level 2', 'Next', false],
      ['Level 3', 'Later', false],
      ['Level 4', 'Later', false],
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(color: Colors.amber.shade50, child: const Padding(padding: EdgeInsets.all(12), child: Text('Illustrative levels. A real pathway needs the issuer\'s own mapping, which is not checked yet.'))),
      h('Where you are'),
      for (final l in levels)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(l[2] as bool ? Icons.check_circle : (l[1] == 'Next' ? Icons.radio_button_checked : Icons.radio_button_unchecked), color: l[1] == 'Later' ? Colors.grey : accent),
          title: Text('${state.trade}: ${l[0]}'),
          subtitle: Text(l[1] as String),
        ),
      h('What Level 2 could open'),
      note('Example text for the demo: more independent work and a stronger case when asking about pay. Real unlocks come from the employer and issuer, not this app.'),
      h('Gaps and what to do'),
      Card(
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orange),
            title: const Text('OSHA 10 card is not verified'),
            subtitle: const Text('Ask the issuer or training provider to verify it.'),
            trailing: TextButton(onPressed: () => open('https://www.careeronestop.org/Toolkit/Training/find-certifications.aspx'), child: const Text('Find')),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Next level course'),
            subtitle: const Text('Look for a local training provider'),
            trailing: TextButton(onPressed: () => open('https://www.careeronestop.org/Toolkit/Training/find-local-training.aspx'), child: const Text('Search')),
          ),
        ]),
      ),
      note('Links go to the public CareerOneStop site. This app has no course feed.'),
    ]);
  }
}

// ---------- Job change kit ----------
class KitPage extends StatelessWidget {
  const KitPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      h('Starting a new job'),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Open to work'), subtitle: const Text('Adds a note to your shared profile. No job listings.'), value: state.openToWork, onChanged: (v) { state.openToWork = v; state.changed(); }),
      Card(
        child: ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Profile last updated 41 days ago (demo)'),
          subtitle: const Text('Add tasks from your last job before you share.'),
        ),
      ),
      h('Share'),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: () => snack(context, 'Demo: would open the phone share sheet'), icon: const Icon(Icons.ios_share), label: const Text('Share link'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Sample QR (demo)'), content: SizedBox(width: 200, height: 200, child: CustomPaint(painter: FakeQr())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), icon: const Icon(Icons.qr_code_2), label: const Text('Show QR'))),
      ]),
      note('Show QR opens a decorative sample. It does not scan.'),
      h('One-page summary for the union hall or site'),
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(state.headline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const Text('Marcus (fictional)', style: TextStyle(color: Colors.black54)),
          const Divider(),
          const Text('Credentials', style: TextStyle(fontWeight: FontWeight.w700)),
          for (final c in state.creds) Text('${c.verified ? "[verified]" : "[not verified]"} ${c.name}'),
          const SizedBox(height: 8),
          const Text('Work done', style: TextStyle(fontWeight: FontWeight.w700)),
          if (state.claims.isEmpty) const Text('Add tasks on the Profile tab.'),
          for (final c in state.claims) Text('- ${c.text} (${provLabel(c.prov).toLowerCase()})'),
        ]),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => snack(context, 'Demo: a real build would produce a PDF to print or send'), icon: const Icon(Icons.print_outlined), label: const Text('Print or save as PDF')),
      const SizedBox(height: 24),
    ]);
  }
}

class FakeQr extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    const n = 21;
    final s = size.width / n;
    var seed = 7;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        final corner = (x < 7 && y < 7) || (x > 13 && y < 7) || (x < 7 && y > 13);
        if (corner) {
          final cx = x % 14 % 7, cy = y % 14 % 7;
          final on = cx == 0 || cx == 6 || cy == 0 || cy == 6 || (cx >= 2 && cx <= 4 && cy >= 2 && cy <= 4);
          if (on) canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);
        } else if (seed % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(x * s, y * s, s, s), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------- Funding finder ----------
class FundingPage extends StatelessWidget {
  const FundingPage({super.key});
  @override
  Widget build(BuildContext context) {
    Widget route(String title, String body, String url) => Card(
          child: ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(body),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => open(url),
          ),
        );
    return ListView(padding: const EdgeInsets.all(16), children: [
      h('Who pays for the next credential?'),
      note('For a gap, these are the usual routes. This app does not handle money or apply for you. Cost and eligibility depend on your state and employer.'),
      route('Ask your employer', 'Many employers pay for required cards or the next level. Ask your foreman or HR before paying.', 'https://www.careeronestop.org/'),
      route('Apprenticeship', 'Paid on-the-job training with classes. Search by trade and state.', 'https://www.apprenticeship.gov/apprenticeship-job-finder'),
      route('Workforce board (American Job Center)', 'Local offices that can point to training funds.', 'https://www.careeronestop.org/LocalHelp/AmericanJobCenters/find-american-job-centers.aspx'),
      route('Local training finder', 'Find providers near you.', 'https://www.careeronestop.org/Toolkit/Training/find-local-training.aspx'),
      note('Public sites, opened in a new tab. Not checked by state in this prototype.'),
    ]);
  }
}

// ---------- New-job checklist ----------
class NewJobPage extends StatelessWidget {
  const NewJobPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    if (!state.codeLinked) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        h('Link your company code'),
        note('Your employer gives you a company code. After linking, you see what they need from you. Try the demo code DEMO-1234.'),
        TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Company code')),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            if (ctrl.text.trim().toUpperCase() == 'DEMO-1234') {
              state.codeLinked = true;
              state.changed();
            } else {
              snack(context, 'That code is not the demo code. Try DEMO-1234.');
            }
          },
          child: const Text('Link code'),
        ),
      ]);
    }
    final done = state.checklist.values.where((v) => v).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      h('Week one at Demo Builders Inc. (fictional)'),
      LinearProgressIndicator(value: done / state.checklist.length),
      note('$done of ${state.checklist.length} done. This list is only for you. Nothing is reported to your employer.'),
      for (final e in state.checklist.entries.toList())
        CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(e.key), value: e.value, onChanged: (v) { state.checklist[e.key] = v!; state.changed(); }),
      h('Who to ask'),
      const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.person_outline), title: Text('Site foreman (demo)'), subtitle: Text('Questions about the job site and schedule')),
      TextButton(onPressed: () { state.codeLinked = false; state.changed(); }, child: const Text('Unlink demo code')),
    ]);
  }
}
