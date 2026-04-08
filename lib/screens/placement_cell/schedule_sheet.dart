import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleInterviewSheet extends StatefulWidget {
  final String placementUid;
  const ScheduleInterviewSheet({super.key, required this.placementUid});

  @override
  State<ScheduleInterviewSheet> createState() => _ScheduleInterviewSheetState();
}

class _ScheduleInterviewSheetState extends State<ScheduleInterviewSheet> {
  String? _selectedJobId;
  String? _selectedAppId;
  
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _modeController = TextEditingController(text: 'Online');

  bool _loading = false;

  Future<void> _submit() async {
    if (_selectedAppId == null || _dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      final appDoc = await FirebaseFirestore.instance.collection('applications').doc(_selectedAppId).get();
      final appData = appDoc.data() as Map<String, dynamic>;
      final studentId = appData['studentId'];
      final company = appData['company'] ?? 'a company';

      await FirebaseFirestore.instance.collection('applications').doc(_selectedAppId).update({
        'status': 'Interview',
        'interviewDate': _dateController.text,
        'interviewTime': _timeController.text,
        'interviewMode': _modeController.text,
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Interview Scheduled',
        'message': 'Your interview for $company is scheduled on ${_dateController.text} at ${_timeController.text}.',
        'type': 'interview',
        'targetUserId': studentId,
        'createdAt': FieldValue.serverTimestamp(),
        'isNew': true,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Schedule Interview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('jobs').where('postedBy', isEqualTo: widget.placementUid).snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final docs = snap.data!.docs;
              return DropdownButtonFormField<String>(
                value: _selectedJobId,
                decoration: InputDecoration(
                  labelText: 'Select Job', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return DropdownMenuItem(value: d.id, child: Text(data['title'] ?? 'Unknown'));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedJobId = v;
                    _selectedAppId = null;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          
          if (_selectedJobId != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('applications').where('jobId', isEqualTo: _selectedJobId).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const LinearProgressIndicator();
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Text('No applicants yet for this job', style: TextStyle(color: Colors.grey));
                
                return DropdownButtonFormField<String>(
                  value: _selectedAppId,
                  decoration: InputDecoration(
                    labelText: 'Select Applicant', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(value: d.id, child: Text('${data['studentName']} (${data['status']})'));
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedAppId = v;
                    });
                  },
                );
              },
            ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _dateController, 
            decoration: InputDecoration(labelText: 'Date (e.g. Apr 10, 2025)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeController, 
            decoration: InputDecoration(labelText: 'Time (e.g. 10:00 AM)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modeController, 
            decoration: InputDecoration(labelText: 'Mode (Online / On-site)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9333EA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
