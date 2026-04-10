import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/checklist_models.dart';
import '../services/pdf_service.dart';
import '../widgets/assinatura_box.dart';
import '../widgets/checklist_item_widget.dart';
import '../screens/calibrador_screen.dart';

class ChecklistCaminhaoScreen extends StatefulWidget {
  const ChecklistCaminhaoScreen({super.key});

  @override
  State<ChecklistCaminhaoScreen> createState() =>
      _ChecklistCaminhaoScreenState();
}

class _ChecklistCaminhaoScreenState extends State<ChecklistCaminhaoScreen> {
  final data = ChecklistCaminhaoData();
  final _pdfService = PdfService();

  // ✅ Controllers para campos de data
  late final TextEditingController _ctrlCnhValidade;
  late final TextEditingController _ctrlDataChegada;
  late final TextEditingController _ctrlDataEntrada;

  @override
  void initState() {
    super.initState();
    _ctrlCnhValidade = TextEditingController(text: data.cnhValidade);
    _ctrlDataChegada = TextEditingController(text: data.dataChegada);
    _ctrlDataEntrada = TextEditingController(text: data.dataEntrada);
  }

  @override
  void dispose() {
    _ctrlCnhValidade.dispose();
    _ctrlDataChegada.dispose();
    _ctrlDataEntrada.dispose();
    super.dispose();
  }

  // requisitos para liberar o PDF
  bool get _itensOk =>
      data.itens.every((i) => i.resposta != null) &&
      data.assinaturaMotoristaPng != null &&
      data.assinaturaVigilantePng != null;

  // -------------------- DATE HELPERS --------------------

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  DateTime? _parseDateBr(String s) {
    final t = s.trim();
    if (t.length != 10) return null;
    try {
      final dd = int.parse(t.substring(0, 2));
      final mm = int.parse(t.substring(3, 5));
      final yyyy = int.parse(t.substring(6, 10));
      return DateTime(yyyy, mm, dd);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate({
    required TextEditingController controller,
    required void Function(String) onSelected,
  }) async {
    final now = DateTime.now();
    final current = _parseDateBr(controller.text) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (picked == null) return;
    final formatted = _fmtDate(picked);

    setState(() {
      controller.text = formatted;
      onSelected(formatted);
    });
  }

  Widget _campoData(
    String label, {
    required TextEditingController controller,
    required void Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_month),
        ),
        onTap: () => _pickDate(controller: controller, onSelected: onSelected),
      ),
    );
  }

  // ----------------------------------------------------------------------
  void _mostrarResumo() {
    final linhas = <String>[
      'Motorista: ${data.motorista}',
      'Transportadora: ${data.transportadora}',
      'Nº Documento: ${data.numeroDocumento}',
      'Senha: ${data.senha}',
      'CNH: ${data.cnhNumero}',
      'Validade CNH: ${data.cnhValidade}',
      'Produto Perigoso: ${data.produtoPerigoso}',
      'MOPP: ${data.mopp}',
      'Placa/Carreta: ${data.placaCarreta}',
      'Placa/Cavalo: ${data.placaCavalo}',
      'Placa veículo perigoso: ${data.placaVeiculoPerigoso}',
      'Placa Utilitário: ${data.placaUtilitario}',
      'Chegada: ${data.horaChegada} ${data.dataChegada}',
      'Entrada: ${data.horaEntrada} ${data.dataEntrada}',
      'Operação: ${data.carregamento == null ? "" : (data.carregamento! ? "Carregamento" : "Descarregamento")}',
      'Vigilante/Vigia: ${data.vigilanteVigia}',
      '--- Itens ---',
    ];
    for (final item in data.itens) {
      linhas.add(
          '${item.numero}) ${item.assunto} => ${item.resposta}  OBS: ${item.obs}');
    }
    linhas.add(
        'Ass. Motorista: ${data.assinaturaMotoristaPng != null ? "OK" : "NÃO"}');
    linhas.add(
        'Ass. Vigilante: ${data.assinaturaVigilantePng != null ? "OK" : "NÃO"}');
    linhas.add('Observações: ${data.observacoes}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resumo'),
        content: SingleChildScrollView(child: Text(linhas.join('\n'))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  Future<void> _gerarPdf() async {
    if (!_itensOk) return;
    // loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 14),
              Expanded(child: Text('Gerando PDF...')),
            ],
          ),
        ),
      ),
    );
    try {
      final bytes = await _pdfService.gerarPdfCaminhao(data);
      if (mounted) Navigator.pop(context);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'checklist_caminhao.pdf',
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro ao gerar PDF'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final infoStatus = _itensOk
        ? 'PDF será gerado conforme o modelo.'
        : 'Preencha todos os itens e assinaturas para gerar o PDF.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // CABEÇALHO
              Row(
                children: const [
                  BackButton(),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Check-list de Caminhão',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _secaoTitulo('Dados'),
                      _campo('Motorista', onChanged: (v) => data.motorista = v),
                      _campo('Transportadora',
                          onChanged: (v) => data.transportadora = v),
                      _campo('Nº Documento',
                          onChanged: (v) => data.numeroDocumento = v),
                      _campo('Senha', onChanged: (v) => data.senha = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('CNH'),
                      _campo('Nº Documento (CNH)',
                          onChanged: (v) => data.cnhNumero = v),
                      // ✅ DATA com calendário
                      _campoData(
                        'Validade CNH (dd/mm/aaaa)',
                        controller: _ctrlCnhValidade,
                        onSelected: (v) => data.cnhValidade = v,
                      ),
                      const SizedBox(height: 10),

                      _secaoTitulo('Produto perigoso'),
                      _simNao(
                        valor: data.produtoPerigoso,
                        onChanged: (v) =>
                            setState(() => data.produtoPerigoso = v),
                      ),
                      _campo('MOPP', onChanged: (v) => data.mopp = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('Horários / Datas'),
                      _campo('Hora/Chegada',
                          onChanged: (v) => data.horaChegada = v),
                      // ✅ DATA com calendário
                      _campoData(
                        'Data/Chegada (dd/mm/aaaa)',
                        controller: _ctrlDataChegada,
                        onSelected: (v) => data.dataChegada = v,
                      ),
                      _campo('Hora/Entrada',
                          onChanged: (v) => data.horaEntrada = v),
                      // ✅ DATA com calendário
                      _campoData(
                        'Data/Entrada (dd/mm/aaaa)',
                        controller: _ctrlDataEntrada,
                        onSelected: (v) => data.dataEntrada = v,
                      ),
                      const SizedBox(height: 10),

                      _secaoTitulo('Placas'),
                      _campo('Placa/Carreta',
                          onChanged: (v) => data.placaCarreta = v),
                      _campo('Placa/Cavalo',
                          onChanged: (v) => data.placaCavalo = v),
                      _campo('Placa veículo perigoso',
                          onChanged: (v) => data.placaVeiculoPerigoso = v),
                      _campo('Placa/Utilitário',
                          onChanged: (v) => data.placaUtilitario = v),
                      const SizedBox(height: 10),

                      _secaoTitulo('Operação'),
                      _carregamentoDescarregamento(
                        valor: data.carregamento,
                        onChanged: (v) => setState(() => data.carregamento = v),
                      ),
                      const SizedBox(height: 10),

                      _secaoTitulo('Vigilante / Vigia'),
                      _campo('Vigilante/Vigia',
                          onChanged: (v) => data.vigilanteVigia = v),
                      const SizedBox(height: 14),

                      _secaoTitulo('Itens a verificar'),
                      for (final item in data.itens)
                        ChecklistItemWidget(
                          item: item,
                          temObs: true,
                          onChanged: (val) =>
                              setState(() => item.resposta = val),
                          onObsChanged: (txt) => item.obs = txt,
                        ),
                      const SizedBox(height: 10),

                      _secaoTitulo('Assinaturas'),
                      AssinaturaBox(
                        titulo: 'Assinatura do Motorista',
                        onSalvar: (bytes) {
                          data.assinaturaMotoristaPng = bytes;
                          setState(() {});
                        },
                      ),
                      AssinaturaBox(
                        titulo: 'Assinatura do Vigilante',
                        onSalvar: (bytes) {
                          data.assinaturaVigilantePng = bytes;
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 10),

                      _secaoTitulo('Observações gerais'),
                      TextField(
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Digite aqui...',
                        ),
                        onChanged: (v) => data.observacoes = v,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _mostrarResumo,
                      child: const Text('Resumo'),
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalibradorScreen(
                              initialTemplate: CalibradorTemplate.caminhao,
                            ),
                          ),
                        );
                      },
                      child: const Text('Calibrar caminhao (mm)'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _itensOk ? _gerarPdf : null,
                      child: const Text('Gerar PDF'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    infoStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // COMPONENTES DE UI -------------------------------------------------------
  Widget _secaoTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _campo(String label, {required void Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _simNao(
      {required bool? valor, required void Function(bool v) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Expanded(child: Text('Produto Perigoso:')),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<bool>(
                value: true,
                groupValue: valor,
                onChanged: (_) => onChanged(true),
              ),
              const Text('SIM'),
              const SizedBox(width: 10),
              Radio<bool>(
                value: false,
                groupValue: valor,
                onChanged: (_) => onChanged(false),
              ),
              const Text('NÃO'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _carregamentoDescarregamento({
    required bool? valor,
    required void Function(bool v) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Expanded(child: Text('Carregamento / Descarregamento:')),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<bool>(
                value: true,
                groupValue: valor,
                onChanged: (_) => onChanged(true),
              ),
              const Text('Carregamento'),
              const SizedBox(width: 10),
              Radio<bool>(
                value: false,
                groupValue: valor,
                onChanged: (_) => onChanged(false),
              ),
              const Text('Descarregamento'),
            ],
          ),
        ],
      ),
    );
  }
}
