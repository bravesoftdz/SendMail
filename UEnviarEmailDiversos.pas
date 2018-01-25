unit UEnviarEmailDiversos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdSMTP, IdSSLOpenSSL, IdMessage, IdText, IdAttachmentFile, IdExplicitTLSClientServerBase,
  Vcl.StdCtrls;

type
  TFrmEnviarEmailDiversos = class(TForm)
    procedure EnviarEmailDiversos(sAnexo, sEmailContabilidade, sCorpoEmail, sAssunto: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmEnviarEmailDiversos: TFrmEnviarEmailDiversos;

implementation

procedure TFrmEnviarEmailDiversos.EnviarEmailDiversos(sAnexo, sEmailContabilidade, sCorpoEmail, sAssunto : string);
var
  // vari�veis e objetos necess�rios para o envio
    IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    IdSMTP: TIdSMTP;
    IdMessage: TIdMessage;
    IdText: TIdText;
begin
  // instancia��o dos objetos
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IdSMTP               := TIdSMTP.Create(Self);
  IdMessage            := TIdMessage.Create(Self);

try
    // Configura��o do protocolo SSL (TIdSSLIOHandlerSocketOpenSSL)
    IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    IdSSLIOHandlerSocket.SSLOptions.Mode   := sslmClient;

    // Configura��o do servidor SMTP (TIdSMTP)
    IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    IdSMTP.UseTLS    := utUseImplicitTLS;
    IdSMTP.AuthType  := satDefault;
    IdSMTP.Port      := 465;
    IdSMTP.Host      := 'smtp.gmail.com';
    IdSMTP.Username  := 'contribuintenfe@gmail.com';
    IdSMTP.Password  := 'ContribuinteNFe@96537807';

    // Configura��o da mensagem (TIdMessage)
    IdMessage.From.Address           := 'contribuintenfe@gmail.com';
    IdMessage.From.Name              := 'Software Contribuinte NFe';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text    := Trim(sEmailContabilidade);
    //IdMessage.Recipients.Add.Text  := 'destinatario2@email.com'; // opcional
    //IdMessage.Recipients.Add.Text  := 'destinatario3@email.com'; // opcional
    IdMessage.Subject                := Trim(sAssunto);
    IdMessage.Encoding               := meMIME;

    // Configura��o do corpo do email (TIdText)
    IdText := TIdText.Create(IdMessage.MessageParts);
    IdText.Body.Add(sCorpoEmail);
    IdText.ContentType := 'text/plain; charset=iso-8859-1';

    // Opcional - Anexo da mensagem (TIdAttachmentFile)
    if FileExists(sAnexo) then
    begin
      TIdAttachmentFile.Create(IdMessage.MessageParts, sAnexo);
    end;

    // Conex�o e autentica��o
    try
      IdSMTP.Connect;
      Application.ProcessMessages;
      IdSMTP.Authenticate;
      Application.ProcessMessages;
    except
      on E:Exception do
      begin
        MessageDlg('Erro na conex�o ou autentica��o: ' +
          E.Message, mtWarning, [mbOK], 0);
        Exit;
      end;
    end;

    // Envio da mensagem
    try
      IdSMTP.Send(IdMessage);
      Application.MessageBox('Arquivos enviados com sucesso!','Envio de arquivos', MB_OK + MB_ICONINFORMATION);
      //MessageDlg('', mtInformation, [mbOK], 0);
    except
      On E:Exception do
      begin
        MessageDlg('Erro ao enviar a mensagem: ' +
          E.Message, mtWarning, [mbOK], 0);
      end;
    end;
  finally
    // desconecta do servidor
    IdSMTP.Disconnect;
    // libera��o da DLL
    UnLoadOpenSSLLibrary;
    // libera��o dos objetos da mem�ria
    FreeAndNil(IdMessage);
    FreeAndNil(IdSSLIOHandlerSocket);
    FreeAndNil(IdSMTP);
  end;
end;

end.

