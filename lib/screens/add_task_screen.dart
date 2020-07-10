import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/helpers/database_helper.dart';
import 'package:todo/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function onFinished;

  AddTaskScreen({this.task, @required this.onFinished});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  String _title;
  String _priority;
  final List<String> _priorities = ['Baixa', 'Média', 'Alta'];
  DateTime _date = DateTime.now();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _onDateFieldTapped() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(_date);
    }
  }

  _onPrioritySelected(String selectedPriority) {
    setState(() {
      _priority = selectedPriority;
    });
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Task task = Task(
        title: _title,
        date: _date,
        priority: _priority,
      );

      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }

      widget.onFinished();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task);
    widget.onFinished();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: 30),
                Text(
                  widget.task == null ? 'Adicionar Tarefa' : 'Editar Tarefa',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Título',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (text) => text.trim().isEmpty
                              ? 'Por favor, insira um título'
                              : null,
                          onSaved: (text) => _title = text,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Data',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (text) => _date == null
                              ? 'Por favor, selecione uma data'
                              : null,
                          onTap: _onDateFieldTapped,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 22,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          onChanged: _onPrioritySelected,
                          items: _priorities.map((priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Prioridade',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (text) => _priority == null
                              ? 'Por favor, selecione uma prioridade'
                              : null,
                          onSaved: (text) => _priority = text,
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: FlatButton(
                          textColor: Theme.of(context).textTheme.button.color,
                          child: Text(
                            'Salvar',
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .button
                                    .fontSize),
                          ),
                          onPressed: _submit,
                        ),
                      ),
                      if (widget.task != null)
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: FlatButton(
                            textColor: Theme.of(context).textTheme.button.color,
                            child: Text(
                              'Excluir',
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .button
                                      .fontSize),
                            ),
                            onPressed: _delete,
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
