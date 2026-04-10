import 'package:flutter/material.dart';
import '../models/checklist_models.dart';

class ChecklistItemWidget extends StatelessWidget {
  final ChecklistItemData item;
  final bool temObs;
  final void Function(RespostaChecklist? value) onChanged;
  final void Function(String value)? onObsChanged;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    required this.onChanged,
    this.temObs = false,
    this.onObsChanged,
  });

  String _labelResposta(RespostaChecklist r) {
    switch (r) {
      case RespostaChecklist.sim:
        return 'SIM';
      case RespostaChecklist.nao:
        return 'NÃO';
      case RespostaChecklist.na:
        return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 13);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linha: número + assunto
          Text(
            '${item.numero}. ${item.assunto}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Opções (sem ícones)
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _radio(RespostaChecklist.sim, textStyle),
              _radio(RespostaChecklist.nao, textStyle),
              _radio(RespostaChecklist.na, textStyle),
            ],
          ),

          if (temObs) ...[
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'OBS',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onObsChanged,
            ),
          ],
        ],
      ),
    );
  }

  Widget _radio(RespostaChecklist value, TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<RespostaChecklist>(
          value: value,
          groupValue: item.resposta,
          onChanged: onChanged,
        ),
        Text(_labelResposta(value), style: textStyle),
      ],
    );
  }
}
