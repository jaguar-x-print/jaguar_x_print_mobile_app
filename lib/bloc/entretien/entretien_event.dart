// Événements
abstract class EntretienEvent {}

class SaveEntretienEvent extends EntretienEvent {
  final Map<String, dynamic> data;

  SaveEntretienEvent(this.data);
}

class EntretienPauseEvent extends EntretienEvent {}
class EntretienResumeEvent extends EntretienEvent {}