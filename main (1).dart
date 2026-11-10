
import 'dart:io';

mixin ActivityLogger {
  void logActivity(String message) {
    print("[ACTIVITY] $message");
  }
}

abstract class CenterRecord {
  String _id;

  CenterRecord(this._id);

  String get id => _id;

  void displayInfo();
}


class LearningResource extends CenterRecord with ActivityLogger {
  String _name;
  String _category;
  bool _isAvailable;
  String? _borrowedBy;

  LearningResource(String id, String name, String category)
      : _name = name,
        _category = category,
        _isAvailable = true,
        _borrowedBy = null,
        super(id);

  String get name => _name;
  String get category => _category;
  bool get isAvailable => _isAvailable;
  String? get borrowedBy => _borrowedBy;

  bool borrow(String participantName) {
    if (!_isAvailable) {
      return false;
    }

    _isAvailable = false;
    _borrowedBy = participantName;

    logActivity("$_name borrowed by $participantName");
    return true;
  }

  bool returnResource() {
    if (_isAvailable) {
      return false;
    }

    _isAvailable = true;
    _borrowedBy = null;

    logActivity("$_name has been returned");
    return true;
  }

  @override
  void displayInfo() {
    print("Resource ID: $id");
    print("Name: $_name");
    print("Category: $_category");
    print("Status: ${_isAvailable ? "Available" : "Borrowed"}");

    if (_borrowedBy != null) {
      print("Borrowed by: $_borrowedBy");
    }
  }
}


class Participant extends CenterRecord with ActivityLogger {
  String _name;
  String _program;
  int _borrowedCount;

  Participant(String id, String name, String program)
      : _name = name,
        _program = program,
        _borrowedCount = 0,
        super(id);

  String get name => _name;
  String get program => _program;
  int get borrowedCount => _borrowedCount;

  void addBorrowedItem() {
    _borrowedCount++;
    logActivity("$_name borrowed a resource");
  }

  void removeBorrowedItem() {
    if (_borrowedCount > 0) {
      _borrowedCount--;
      logActivity("$_name returned a resource");
    }
  }

  @override
  void displayInfo() {
    print("Participant ID: $id");
    print("Name: $_name");
    print("Program: $_program");
    print("Borrowed Resources: $_borrowedCount");
  }
}

List<LearningResource> resources = [];

Map<String, Participant> participants = {};

int resourceCounter = 1;
int participantCounter = 1;


String getInput(String message) {
  stdout.write(message);
  return stdin.readLineSync()?.trim() ?? "";
}

int? getNumber(String message) {
  String input = getInput(message);
  return int.tryParse(input);
}


void addResource(String name, String category) {
  String id = "R${resourceCounter.toString().padLeft(3, '0')}";

  LearningResource resource =
      LearningResource(id, name, category);

  resources.add(resource);
  resourceCounter++;

  print("Resource successfully added!");
  print("Resource ID: $id");
}


void registerParticipant(String name, String program) {
  String id = "P${participantCounter.toString().padLeft(3, '0')}";

  Participant participant =
      Participant(id, name, program);

  participants[id] = participant;
  participantCounter++;

  print("Participant successfully registered!");
  print("Participant ID: $id");
}


void borrowResource(String resourceId, String participantId) {
  Participant? participant = participants[participantId];

  if (participant == null) {
    print("Participant not found!");
    return;
  }

  LearningResource? resource;

  for (var item in resources) {
    if (item.id == resourceId) {
      resource = item;
      break;
    }
  }

  if (resource == null) {
    print("Resource not found!");
    return;
  }

  if (resource.borrow(participant.name)) {
    participant.addBorrowedItem();
    print("Resource borrowed successfully!");
  } else {
    print("Sorry, this resource is already borrowed.");
  }
}



void returnResource(String resourceId) {
  LearningResource? resource;

  for (var item in resources) {
    if (item.id == resourceId) {
      resource = item;
      break;
    }
  }

  if (resource == null) {
    print("Resource not found!");
    return;
  }

  String? borrower = resource.borrowedBy;

  if (resource.returnResource()) {
    Participant? participant;

    for (var item in participants.values) {
      if (item.name == borrower) {
        participant = item;
        break;
      }
    }

    participant?.removeBorrowedItem();

    print("Resource returned successfully!");
  } else {
    print("This resource is already available.");
  }
}


void viewAllRecords() {
  print("\n========== ALL RECORDS ==========");

  if (resources.isEmpty && participants.isEmpty) {
    print("No records available.");
    return;
  }

  List<CenterRecord> allRecords = [];

  allRecords.addAll(resources);
  allRecords.addAll(participants.values);

  for (CenterRecord record in allRecords) {
    record.displayInfo();
    print("---------------------------------");
  }
}


void displayReport() {
  int availableCount = 0;
  int borrowedCount = 0;

  for (var resource in resources) {
    if (resource.isAvailable) {
      availableCount++;
    } else {
      borrowedCount++;
    }
  }

  print("\n========== CENTER REPORT ==========");
  print("Total Resources: ${resources.length}");
  print("Available Resources: $availableCount");
  print("Borrowed Resources: $borrowedCount");
  print("Total Participants: ${participants.length}");

  print("===================================");
}


void main() {
  int selectedOption = 0;

  do {
    print("\n______________________________________");
    print("        COMMUNITY LEARNING CENTER");
    print("                 SYSTEM");
    print("______________________________________");

    print("[1] Add Learning Resource");
    print("[2] Register Participant");
    print("[3] Borrow Resource");
    print("[4] Return Resource");
    print("[5] View All Records");
    print("[6] View Center Report");
    print("[7] Exit");

    print("========================================");

    int? choice = getNumber("Enter your choice: ");

    if (choice == null) {
      print("Invalid input! Please enter a number.");
      continue;
    }

    selectedOption = choice;

    try {
      switch (selectedOption) {
        case 1:
          print("\n=== ADD LEARNING RESOURCE ===");

          String name = getInput("Resource name: ");
          String category = getInput("Category: ");

          if (name.isEmpty || category.isEmpty) {
            print("Please complete all fields.");
          } else {
            addResource(name, category);
          }
          break;

        case 2:
          print("\n=== REGISTER PARTICIPANT ===");

          String name = getInput("Participant name: ");
          String program = getInput("Program: ");

          if (name.isEmpty || program.isEmpty) {
            print("Please complete all fields.");
          } else {
            registerParticipant(name, program);
          }
          break;

        case 3:
          print("\n=== BORROW RESOURCE ===");

          if (resources.isEmpty || participants.isEmpty) {
            print("You need at least one resource and participant.");
          } else {
            print("Available Resources:");

            for (var resource in resources) {
              if (resource.isAvailable) {
                print("${resource.id} - ${resource.name}");
              }
            }

            print("\nRegistered Participants:");

            for (var participant in participants.values) {
              print("${participant.id} - ${participant.name}");
            }

            String resourceId =
                getInput("\nEnter Resource ID: ").toUpperCase();

            String participantId =
                getInput("Enter Participant ID: ").toUpperCase();

            borrowResource(resourceId, participantId);
          }
          break;

        case 4:
          print("\n=== RETURN RESOURCE ===");

          if (resources.isEmpty) {
            print("No resources have been registered.");
          } else {
            print("Borrowed Resources:");

            for (var resource in resources) {
              if (!resource.isAvailable) {
                print("${resource.id} - ${resource.name}");
              }
            }

            String resourceId =
                getInput("\nEnter Resource ID: ").toUpperCase();

            returnResource(resourceId);
          }
          break;

        case 5:
          viewAllRecords();
          break;

        case 6:
          displayReport();
          break;

        case 7:
          print("Thank you for using the system!");
          break;

        default:
          print("Invalid option! Choose from 1 to 7.");
      }
    } catch (e) {
      print("An error occurred: $e");
    }

  } while (selectedOption != 7);
}
