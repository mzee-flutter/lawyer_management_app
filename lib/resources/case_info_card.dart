import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';

class CaseInfoCard extends StatelessWidget {
  final CaseModel clientCase;
  const CaseInfoCard({super.key, required this.clientCase});

  @override
  Widget build(BuildContext context) {
    return Consumer<CaseViewModel>(
      builder: (context, caseVM, child) {
        return Card(
          color: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title and Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        clientCase.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        clientCase.status,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: clientCase.status == 'Open'
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Sub Info
                Text(
                  "Client ID: ${clientCase.clientId}",
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 4),
                Text(
                  "Description: ${clientCase.description}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                // Date (optional)
                Text(
                  "Added on: ${DateFormat.yMMMd().format(clientCase.createdAt)}",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blueAccent),
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (_) => CaseDetailScreen(caseData: caseData),
                        //     ));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orangeAccent),
                      onPressed: () {
                        // Open Edit Screen
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        // Delete confirmation
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
