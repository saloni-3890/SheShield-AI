import 'package:flutter/material.dart';
import '../services/safe_journey_service.dart';

class SafeJourneyScreen extends StatefulWidget {
  const SafeJourneyScreen({super.key});

  @override
  State<SafeJourneyScreen> createState() => _SafeJourneyScreenState();
}

class _SafeJourneyScreenState extends State<SafeJourneyScreen> {
  final destinationController = TextEditingController();

  DateTime? expectedArrival;

  Map<String, dynamic>? activeJourney;

  bool loading = true;
  bool actionLoading = false;

  @override
  void initState() {
    super.initState();
    loadActiveJourney();
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  Future<void> loadActiveJourney() async {
    try {
      final journey = await SafeJourneyService.getActiveJourney();

      if (!mounted) return;

      setState(() {
        activeJourney = journey;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> selectArrivalTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        now.add(const Duration(hours: 1)),
      ),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (selected.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future arrival time.'),
        ),
      );
      return;
    }

    setState(() {
      expectedArrival = selected;
    });
  }

  Future<void> startJourney() async {
    if (destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your destination.'),
        ),
      );
      return;
    }

    if (expectedArrival == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select expected arrival time.'),
        ),
      );
      return;
    }

    setState(() {
      actionLoading = true;
    });

    try {
      await SafeJourneyService.startJourney(
        destination: destinationController.text.trim(),
        expectedArrival: expectedArrival!,
      );

      if (!mounted) return;

      destinationController.clear();

      setState(() {
        expectedArrival = null;
      });

      await loadActiveJourney();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛡️ Safe Journey started successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  Future<void> checkIn() async {
    setState(() {
      actionLoading = true;
    });

    try {
      await SafeJourneyService.checkIn();

      await loadActiveJourney();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Check-in successful!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  Future<void> completeJourney() async {
    setState(() {
      actionLoading = true;
    });

    try {
      await SafeJourneyService.completeJourney();

      await loadActiveJourney();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Journey completed safely!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  Future<void> cancelJourney() async {
    setState(() {
      actionLoading = true;
    });

    try {
      await SafeJourneyService.cancelJourney();

      await loadActiveJourney();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journey cancelled.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  String formatDateTime(dynamic value) {
    if (value == null) return 'Not available';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Not available';

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }

  Widget buildActiveJourney() {
    final journey = activeJourney!;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield,
                    color: Colors.green.shade700,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Text(
                    'Journey Active',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _infoRow(
              Icons.location_on,
              'Destination',
              journey['destination'] ?? 'Unknown',
            ),

            const SizedBox(height: 16),

            _infoRow(
              Icons.access_time,
              'Expected Arrival',
              formatDateTime(journey['expectedArrival']),
            ),

            const SizedBox(height: 16),

            _infoRow(
              Icons.check_circle_outline,
              'Last Check-In',
              formatDateTime(journey['lastCheckIn']),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: actionLoading ? null : checkIn,
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'CHECK IN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        actionLoading ? null : completeJourney,
                    child: const Text('Complete'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        actionLoading ? null : cancelJourney,
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: Colors.pink,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStartJourney() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),

          Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 65,
                color: Colors.pink,
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'Safe Journey',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Let someone know you are on your way.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 35),

          TextField(
            controller: destinationController,
            decoration: const InputDecoration(
              labelText: 'Destination',
              hintText: 'e.g. College, Home, Metro Station',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          InkWell(
            onTap: selectArrivalTime,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Expected Arrival',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              child: Text(
                expectedArrival == null
                    ? 'Select arrival time'
                    : formatDateTime(expectedArrival),
                style: TextStyle(
                  color: expectedArrival == null
                      ? Colors.grey.shade600
                      : Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: actionLoading ? null : startJourney,
              icon: actionLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(
                actionLoading
                    ? 'STARTING...'
                    : 'START SAFE JOURNEY',
              ),
            ),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Check in during your journey and mark it complete when you reach your destination safely.',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safe Journey',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : activeJourney != null
              ? SingleChildScrollView(
                  child: buildActiveJourney(),
                )
              : buildStartJourney(),
    );
  }
}