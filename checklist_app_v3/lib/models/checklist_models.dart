import 'dart:typed_data';

enum RespostaChecklist { sim, nao, na }

class ChecklistItemData {
  final int numero;
  final String assunto;
  RespostaChecklist? resposta;
  String obs;

  ChecklistItemData({
    required this.numero,
    required this.assunto,
    this.resposta,
    this.obs = '',
  });
}

class ChecklistCacambaData {
  // Campos (cabeçalho)
  String motorista = '';
  String transportadora = '';
  String vigilante = '';

  String placaCarreta = '';
  String placaCavalo = '';
  String numeroCacamba = '';

  String dataChegada = ''; // dd/mm/aaaa
  String horaChegada = ''; // hh:mm

  String ticketEntrada = '';
  String dataEntrada = '';
  String horaEntrada = '';

  String observacoes = '';

  Uint8List? assinaturaMotoristaPng;
  Uint8List? assinaturaVigilantePng;

  // Itens (6)
  final List<ChecklistItemData> itens = [
    ChecklistItemData(
        numero: 1,
        assunto:
            'Caçamba está em boas condições ?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
    ChecklistItemData(
        numero: 2,
        assunto:
            'Trava superior está funcionando ?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
    ChecklistItemData(
        numero: 3,
        assunto:
            'Trava inferior está funcionando ?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
    ChecklistItemData(
        numero: 4,
        assunto:
            'Escadas estão em boas condições?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
    ChecklistItemData(
        numero: 5,
        assunto:
            'A caçamba detém Lona ?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
    ChecklistItemData(
        numero: 6,
        assunto:
            'A Caçamba detém cinta?'), // [2](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_cacamba.pdf)
  ];
}

class ChecklistCaminhaoData {
  // Campos (cabeçalho)
  String motorista = '';
  String transportadora = '';
  String numeroDocumento = '';
  String senha = '';

  String cnhNumero = '';
  String cnhValidade = '';

  bool? produtoPerigoso; // true = SIM, false = NÃO, null = não marcado
  String mopp = '';

  String placaCarreta = '';
  String placaCavalo = '';
  String placaVeiculoPerigoso = '';
  String placaUtilitario = '';

  String horaChegada = '';
  String dataChegada = '';
  String horaEntrada = '';
  String dataEntrada = '';

  bool?
      carregamento; // true = Carregamento, false = Descarregamento, null = não marcado

  String vigilanteVigia = '';
  String observacoes = '';

  Uint8List? assinaturaMotoristaPng;
  Uint8List? assinaturaVigilantePng;

  // Itens (15) + OBS por item
  final List<ChecklistItemData> itens = [
    ChecklistItemData(
        numero: 1,
        assunto:
            'Veículo está em boas condições ?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 2,
        assunto:
            'Buzina ?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 3,
        assunto:
            'Farol ?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 4,
        assunto:
            'Pisca alerta ?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 5,
        assunto:
            'Sirene de ré ?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 6,
        assunto:
            'Os pneus estão em boas confições?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 7,
        assunto:
            'Freio?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
      numero: 8,
      assunto:
          'O motorista utiliza sapato de fechado, calça comprida e camisa com manga comprida?',
    ), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
      numero: 9,
      assunto:
          'O motorista está ciente de que para acessar o prédio precisa utilizar: Capacete com jugular, protetor auricular, óculos e sapato de segurança?',
    ), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 10,
        assunto:
            'Carteira de motorista está válida?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 11,
        assunto:
            'Existe algum tipo de vazamento no caminhão?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
      numero: 12,
      assunto:
          'O motorista foi informado sobre as regras de segurança e meio ambiente da MAG?',
    ), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 13,
        assunto:
            'Placa da ONU?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
        numero: 14,
        assunto:
            'Extintores?'), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
    ChecklistItemData(
      numero: 15,
      assunto:
          'Carroceria / assoalho de carretas e caminhões em condições seguras de uso?',
    ), // [1](https://gonvarri-my.sharepoint.com/personal/samuel_silva_mag-alianca_com_br/Documents/Arquivos%20de%20Microsoft%20Copilot%20Chat/checklist_caminhao.pdf)
  ];
}
