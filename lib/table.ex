defmodule ExCnab.Table do
    @structure %{
        register_types: [
          header_file: 0,
          header_batch: 1,
          init_batch: 2,
          detail: 3,
          final_batch: 4,
          trailer_batch: 5,
          trailer_file: 9
        ]
      }
    @tables %{
        services: %{
            "Cobrança" => "01",
            "Boleto de Pagamento Eletrônico" => "03",
            "Conciliação Bancária" => "04",
            "Débitos" => "05",
            "Custódia de Cheques" => "06",
            "Gestão de Caixa" => "07",
            "Consulta/Informação Margem" => "08",
            "Averbação da Consignação/Retenção" => "09",
            "Pagamento Dividendos" => "10",
            "Manutenção da Consignação" => "11",
            "Consignação de Parcelas" => "12",
            "Glosa da Consignação (INSS)" => "13",
            "Consulta de Tributos a pagar" => "14",
            "Pagamento Fornecedor" => "20",
            "Pagamento de Contas, Tributos e Impostos" => "22",
            "Interoperabilidade entre Contas de Instituições de Pagamentos" => "23",
            "Compror" => "25",
            "Compror Rotativo" => "26",
            "Alegação do Pagador" => "29",
            "Pagamento Salários" => "30",
            "Pagamento de honorários" => "32",
            "Pagamento de bolsa auxílio" => "33",
            "Pagamento de prebenda (remuneração a padres e sacerdotes)" => "34",
            "Vendor" => "40",
            "Vendor a Termo" => "41",
            "Pagamento Sinistros Segurados" => "50",
            "Pagamento Despesas Viajante em Trânsito" => "60",
            "Pagamento Autorizado" => "70",
            "Pagamento Credenciados" => "75",
            "Pagamento de Remuneração" => "77",
            "Pagamento Representantes / Vendedores Autorizados" => "80",
            "Pagamento Benefícios" => "90",
            "Pagamentos Diversos" => "98"
        },
        book_entry_type: %{
            "Crédito em Conta Corrente/Salário" => "01",
            "Cheque Pagamento / Administrativo" => "02",
            "DOC/TED" => "03",
            "Cartão Salário" => "04",
            "Crédito em Conta Poupança" => "05",
            "OP à Disposição" => "10",
            "Pagamento de Contas e Tributos com Código de Barras" => "11",
            "Tributo - DARF Normal" => "16",
            "Tributo - GPS (Guia da Previdência Social)" => "17",
            "Tributo - DARF Simples" => "18",
            "Tributo - IPTU – Prefeituras" => "19",
            "Pagamento com Autenticação" => "20",
            "Tributo – DARJ" => "21",
            "Tributo - GARE-SP ICMS" => "22",
            "Tributo - GARE-SP DR" => "23",
            "Tributo - GARE-SP ITCMD" => "24",
            "Tributo - IPVA" => "25",
            "Tributo - Licenciamento" => "26",
            "Tributo – DPVAT" => "27",
            "Liquidação de Títulos do Próprio Banco" => "30",
            "Pagamento de Títulos de Outros Bancos" => "31",
            "Extrato de Conta Corrente" => "40",
            "TED – Outra Titularidade" => "41",
            "TED – Mesma Titularidade" => "43",
            "TED para Transferência de Conta Investimento" => "44",
            "Débito em Conta Corrente" => "50",
            "Extrato para Gestão de Caixa" => "70",
            "Depósito Judicial em Conta Corrente" => "71",
            "Depósito Judicial em Poupança" => "72",
            "Extrato de Conta Investimento" => "73"
        },
        fiscal_type: %{
            "Isento" => "0",
            "Não Informado" => "0",
            "CPF" => "1",
            "CGC" => "2",
            "CNPJ" => "2",
            "PIS" => "3",
            "PASEP" => "3",
            "Outros" => "9"
        },
        movement_type: %{
            "INCLUSÃO" => "0",
            "CONSULTA" => "1",
            "SUSPENSÃO" => "2",
            "ESTORNO "=> "3",
            "REATIVAÇÃO" => "4",
            "ALTERAÇÃO" => "5",
            "LIQUIDAÇAO" => "7",
            "EXCLUSÃO" => "9"
        },
        movement_code: %{
            "Inclusão de Registro Detalhe Liberado" => "00",
            "Inclusão do Registro Detalhe Bloqueado" => "09",
            "Alteração do Pagamento Liberado para Bloqueado (Bloqueio)" => "10",
            "Alteração do Pagamento Bloqueado para Liberado (Liberação)" => "11",
            "Alteração do Valor do Título" => "17",
            "Alteração da Data de Pagamento" => "19",
            "Pagamento Direto ao Fornecedor - Baixar" => "23",
            "Manutenção em Carteira - Não Pagar" => "25",
            "Retirada de Carteira - Não Pagar" => "27",
            "Estorno por Devolução da Câmara Centralizadora" => "33",
            "Alegação do Pagador" => "40",
            "Exclusão do Registro Detalhe Incluído Anteriormente" => "99"
        },
        payment_type: %{
            "Débito em Conta Corrente" => "01",
            "Débito Empréstimo/Financiamento" => "02",
            "Débito em Cartão de Crédito" => "03"
        },

        warning: %{
            "Não Emite Aviso" => "0",
            "Emite Aviso Somente para o Remetente" => "2",
            "Emite Aviso Somente para o Favorecido" => "5",
            "Emite Aviso para o Remetente e Favorecido" => "6",
            "Emite Aviso para o Favorecido e 2 Vias para o Remetente" => "7"
        },
        ocurrences: %{
            "Crédito ou Débito Efetivado" => "00",
            "Insuficiência de Fundos - Débito Não Efetuado" => "01",
            "Crédito ou Débito Cancelado pelo Pagador/Credor" => "02",
            "Débito Autorizado pela Agência - Efetuado" => "03",
            "Controle Inválido" => "AA",
            "Tipo de Operação Inválido" => "AB",
            "Tipo de Serviço Inválido" => "AC",
            "Forma de Lançamento Inválida" => "AD",
            "Tipo/Número de Inscrição Inválido" => "AE",
            "Código de Convênio Inválido" => "AF",
            "Agência/Conta Corrente/DV Inválido" => "AG",
            "No Seqüencial do Registro no Lote Inválido" => "AH",
            "Código de Segmento de Detalhe Inválido" => "AI",
            "Tipo de Movimento Inválido" => "AJ",
            "Código da Câmara de Compensação do Banco Favorecido/Depositário Inválido" => "AK",
            "Código do Banco Favorecido, Instituição de Pagamento ou Depositário Inválido" => "AL",
            "Agência Mantenedora da Conta Corrente do Favorecido Inválida" => "AM",
            "Conta Corrente/DV/Conta de Pagamento do Favorecido Inválido" => "AN",
            "Nome do Favorecido Não Informado" => "AO",
            "Data Lançamento Inválido" => "AP",
            "Tipo/Quantidade da Moeda Inválido" => "AQ",
            "Valor do Lançamento Inválido" => "AR",
            "Aviso ao Favorecido - Identificação Inválida" => "AS",
            "Tipo/Número de Inscrição do Favorecido Inválido" => "AT",
            "Logradouro do Favorecido Não Informado" => "AU",
            "No do Local do Favorecido Não Informado" => "AV",
            "Cidade do Favorecido Não Informada" => "AW",
            "CEP/Complemento do Favorecido Inválido" => "AX",
            "Sigla do Estado do Favorecido Inválida" => "AY",
            "Código/Nome do Banco Depositário Inválido" => "AZ",
            "Código/Nome da Agência Depositária Não Informado" => "BA",
            "Seu Número Inválido" => "BB",
            "Nosso Número Inválido" => "BC",
            "Inclusão Efetuada com Sucesso" => "BD",
            "Alteração Efetuada com Sucesso" => "BE",
            "Exclusão Efetuada com Sucesso" => "BF",
            "Agência/Conta Impedida Legalmente" => "BG",
            "Empresa não pagou salário" => "BH",
            "Falecimento do mutuário" => "BI",
            "Empresa não enviou remessa do mutuário" => "BJ",
            "Empresa não enviou remessa no vencimento" => "BK",
            "Valor da parcela inválida" => "BL",
            "Identificação do contrato inválida" => "BM",
            "Operação de Consignação Incluída com Sucesso" => "BN",
            "Operação de Consignação Alterada com Sucesso" => "BO",
            "Operação de Consignação Excluída com Sucesso" => "BP",
            "Operação de Consignação Liquidada com Sucesso" => "BQ",
            "Reativação Efetuada com Sucesso" => "BR",
            "Suspensão Efetuada com Sucesso" => "BS",
            "Código de Barras - Código do Banco Inválido" => "CA",
            "Código de Barras - Código da Moeda Inválido" => "CB",
            "Código de Barras - Dígito Verificador Geral Inválido" => "CC",
            "Código de Barras - Valor do Título Inválido" => "CD",
            "Código de Barras - Campo Livre Inválido" => "CE",
            "Valor do Documento Inválido" => "CF",
            "Valor do Abatimento Inválido" => "CG",
            "Valor do Desconto Inválido" => "CH",
            "Valor de Mora Inválido" => "CI",
            "Valor da Multa Inválido" => "CJ",
            "Valor do IR Inválido" => "CK",
            "Valor do ISS Inválido" => "CL",
            "Valor do IOF Inválido" => "CM",
            "Valor de Outras Deduções Inválido" => "CN",
            "Valor de Outros Acréscimos Inválido" => "CO",
            "Valor do INSS Inválido" => "CP",
            "Lote Não Aceito" => "HA",
            "Inscrição da Empresa Inválida para o Contrato" => "HB",
            "Convênio com a Empresa Inexistente/Inválido para o Contrato" => "HC",
            "Agência/Conta Corrente da Empresa Inexistente/Inválido para o Contrato" => "HD",
            "Tipo de Serviço Inválido para o Contrato" => "HE",
            "Conta Corrente da Empresa com Saldo Insuficiente" => "HF",
            "Lote de Serviço Fora de Seqüência" => "HG",
            "Lote de Serviço Inválido" => "HH",
            "Arquivo não aceito" => "HI",
            "Tipo de Registro Inválido" => "HJ",
            "Código Remessa / Retorno Inválido" => "HK",
            "Versão de layout inválida" => "HL",
            "Mutuário não identificado" => "HM",
            "Tipo do beneficio não permite empréstimo" => "HN",
            "Beneficio cessado/suspenso" => "HO",
            "Beneficio possui representante legal" => "HP",
            "Beneficio é do tipo PA (Pensão alimentícia)" => "HQ",
            "Quantidade de contratos permitida excedida" => "HR",
            "Beneficio não pertence ao Banco informado" => "HS",
            "Início do desconto informado já ultrapassado" => "HT",
            "Número da parcela inválida" => "HU",
            "Quantidade de parcela inválida" => "HV",
            "Margem consignável excedida para o mutuário dentro do prazo do contrato" => "HW",
            "Empréstimo já cadastrado" => "HX",
            "Empréstimo inexistente" => "HY",
            "Empréstimo já encerrado" => "HZ",
            "Arquivo sem trailer" => "H1",
            "Mutuário sem crédito na competência" => "H2",
            "Não descontado – outros motivos" => "H3",
            "Retorno de Crédito não pago" => "H4",
            "Cancelamento de empréstimo retroativo" => "H5",
            "Outros Motivos de Glosa" => "H6",
            "Margem consignável excedida para o mutuário acima do prazo do contrato" => "H7",
            "Mutuário desligado do empregador" => "H8",
            "Mutuário afastado por licença" => "H9",
            "Primeiro nome do mutuário diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benefício" => "IA",
            "Benefício suspenso/cessado pela APS ou Sisobi" => "IB",
            "Benefício suspenso por dependência de cálculo" => "IC",
            "Benefício suspenso/cessado pela inspetoria/auditoria" => "ID",
            "Benefício bloqueado para empréstimo pelo beneficiário" => "IE",
            "Benefício bloqueado para empréstimo por TBM" => "IF",
            "Benefício está em fase de concessão de PA ou desdobramento" => "IG",
            "Benefício cessado por óbito" => "IH",
            "Benefício cessado por fraude" => "II",
            "Benefício cessado por concessão de outro benefício" => "IJ",
            "Benefício cessado: estatutário transferido para órgão de origem" => "IK",
            "Empréstimo suspenso pela APS" => "IL",
            "Empréstimo cancelado pelo banco" => "IM",
            "Crédito transformado em PAB" => "IN",
            "Término da consignação foi alterado" => "IO",
            "Fim do empréstimo ocorreu durante período de suspensão ou concessão" => "IP",
            "Empréstimo suspenso pelo banco" => "IQ",
            "Não averbação de contrato – quantidade de parcelas/competências informadas ultrapassou a data limite da extinção de cota do dependente titular, de benefícios" => "IR",
            "Lote Não Aceito - Totais do Lote com Diferença" => "TA",
            "Título Não Encontrado" => "YA",
            "Identificador Registro Opcional Inválido" => "YB",
            "Código Padrão Inválido" => "YC",
            "Código de Ocorrência Inválido" => "YD",
            "Complemento de Ocorrência Inválido" => "YE",
            "Alegação já Informada Observação: As ocorrências iniciadas com 'ZA' tem caráter informativo para o cliente" => "YF",
            "Agência / Conta do Favorecido Substituída" => "ZA",
            "Divergência entre o primeiro e último nome do beneficiário versus primeiro e último nome na Receita Federal" => "ZB",
            "Confirmação de Antecipação de Valor" => "ZC",
            "Antecipação parcial de valor" => "ZD",
            "Título bloqueado na base" => "ZE",
            "Sistema em contingência – título valor maior que referência" => "ZF",
            "Sistema em contingência – título vencido" => "ZG",
            "Sistema em contingência – título indexado" => "ZH",
            "Beneficiário divergente" => "ZI",
            "Limite de pagamentos parciais excedido" => "ZJ",
            "Boleto já liquidado" => "ZK"
        },
        file_code: %{
            "Remessa" => "1",
            "Retorno" => "2"
        },
        initial_balance_situation: %{
            "Credor" => "C",
            "Devedor" => "D"
        },
        initial_balance_status: %{
            "Parcial" => "P",
            "Final" => "F",
            "Intra-Dia" => "I"
        },
        balance_nature: %{
            "Disponível" => "DPV",
            "Vinculado" => "SCR",
            "Bloqueado" => "SSR",
            "Somatório dos Saldos" => "SDS",
        }
    }

    def tables, do: @tables
    def structure, do: @structure
end
