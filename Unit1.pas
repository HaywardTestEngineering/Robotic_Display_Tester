unit Unit1;
//----------------------------------------------------------------------------------------
//-- COMPILER : Delphi 5 (updated to Delphi XE4)
//-- COMPORT  : TComport 2.62 (Updated to TVaComm)
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
//-- Aqua Logic Final Assembly ATE test code.
//----------------------------------------------------------------------------------------
//-- VERSION
//-- 1.00    02/27/04 - initial release.
//-- 1.01    03/05/04 - Activated Qdb datalogging.
//-- 1.02    03/10/04 - Fixed error with FUNC TEST x assignment.
//-- 1.03    03/11/04 - Forcing model & serial to uppercase.
//-- 1.04    03/15/04 - Fixed START button focus.
//-- 1.05    03/22/04 - Added LCD display verification at start of testing.
//-- 1.06    03/31/04 - Fixed error in TASK_NUM=3 where DUT's programmed with wrong PSx number
//--                    were not being failed.
//-- 1.07    04/02/04 - Changed barcode routine to distinguish between 'AQL-LOCAL-PS-4' style
//--                    barcodes and '018005A-2 1234 56789' style barcodes.
//--                    Fixed bug where null model_number and serial_number fields were
//--                    accepted as valid.
//-- 1.08    04/15/04 - Put Repeat Until loop in testing routine so that the operator does
//--                    not have to press the START button to begin the next test.  The barcode
//--                    request screen will automatically be displayed.
//-- 1.09    05/10/04 - Changed memory release from 'destroy' to 'free' in
//--                    function Tusenamepassword.Valid.
//-- 1.10    09/27/04 - Finished adding code for PS16 testing.
//-- 1.11    07/05/05 - Added Testcode path to Configuration to allow repair dept to have separate
//--                    use of code.
//-- 1.12    10/17/05 - Changed procedure Write_Result so that Qdb datafile is not written to
//--                    if Qdb is disabled.
//-- 1.13    12/07/05 - Update Barcode unit to recognize 'GLX' model numbers.
//-- 1.14    02/06/08 - Modified Tbarcode.Edit2Enter() routine to recognize '018' and G1-018'
//--                    as single barcode scans.
//-- 1.15    06/23/08 - added code to test Rite Pro displays
//-- 1.16    02/10/10 - Modified Tbarcode.Edit2Enter() routine to recognize 'G018'
//--                    as single barcode scan.
//-- 1.17    02/28/11 - Bypassed username/password validation routines.
//--                    Commented out WINEXEC() in Write_Result.
//-- 1.18    05/05/15 - Modernized code using TMS components.
//--                    Recompiled in Delphi XE4.
//--                    Added modern dBInterface capability.
//-- 1.20    06/10/15 - Added workaround for testing AQL-WW-P4 DUT under 'P4LOCAL' procedure.
//----------------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, VaComm, VaClasses, VaSystem, Vcl.ComCtrls,strutils;

const
     VERSION         = '01.20';
     LAST_TASK       = $FFFF;

     OUTPUT_FILENAME       = 'C:\Program files\goldline\TEST_UPDATES.TXT';
     LOCAL_OUTPUT_FILENAME = 'LOCAL_TEST_UPDATES.TXT';
     APPLICATION_FILENAME  = 'C:\Program files\goldline\TEST_UPDATES.EXE';
     TESTCODE_PATH         = 'F:\Groups\Test Engineering\Aqua Logic Control Pad Final Test';
//--     TESTCODE_PATH         = 'C:\Program files\goldline\local test code';
     DELIMITER             = #9;
     PROCESS_STEP          = '1000';
     FIXTURE               = '52';
     CR = #$0D;
     LF = #$0A;
     CRLF = #$0D#$0A;

type
        Tswitch_type = (SW0,SW1,SW2,SW3,SW4,SW5,SW6,SW7,SW8,SW9,SW10,SW11,SW12,SW13,SW14,
                       SW15,SW16,SW17,SW18,SW19,SW20,SW21,SW22,SW23,SW24,SW25,SW26);


  TForm1 = class(TForm)
    Start: TButton;
    closebtn: TButton;
//    ComPort1: TComPort; // Using VaComm instead of ComPort
    Timer1: TTimer;
    Memo1: TMemo;
    Symptom: TStaticText;
    Stop: TButton;
    PassFail: TStaticText;
    StaticText1: TStaticText;
    Status: TButton;
    MainMenu1: TMainMenu;
    Settings1: TMenuItem;
    Comport1RS4821: TMenuItem;
    Ver_Label: TLabel;
    Configuration1: TMenuItem;
    Label1: TLabel;
    Timer2: TTimer;
//    ComDataPacket1: TComDataPacket; // using VaCapture instead of ComDataPacket
    Label2: TLabel;
    Label3: TLabel;
    DisplayComport: TVaComm;
    DisplayComDataPacket1: TVaCapture;
    Database1: TMenuItem;
    displayprogcomport: TVaComm;
    genIbasecomport: TVaComm;
    genIIbasecomport: TVaComm;
    robotcomport: TVaComm;
    Positiontable1: TMenuItem;
    StatusBar1: TStatusBar;
    robotOFF1: TMenuItem;
    procedure closebtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
//    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StatusClick(Sender: TObject);
    procedure Comport1RS4821Click(Sender: TObject);
    procedure Configuration1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
//    procedure ComDataPacket1Packet(Sender: TObject; const Str: String);
    procedure ComDataPacket1Discard(Sender: TObject; const Str: String);
    procedure DisplayComDataPacket1Message(Sender: TObject; const Data: AnsiString);
    procedure Settings1Click(Sender: TObject);
    procedure Database1Click(Sender: TObject);
    procedure robotcomportRxChar(Sender: TObject; Count: Integer);
    procedure Positiontable1Click(Sender: TObject);
    procedure robotbtnClick(Sender: TObject);
    procedure robotOFF1Click(Sender: TObject);
  private
    { Private declarations }
    homedir : ansistring;
    Testing_enabled : boolean;

    procedure Write_Result(symptom,model_number,serial_number:string);
    procedure Send_Button_Request_Command;
    procedure Program_Device_Type;
    procedure Send_Enter_Testmode_Command;
//--    Procedure YDelay(Millisec : word);
    Procedure XDelay(Millisec : word);
    procedure Init_Everything;
    procedure robot_moveXY(Xstr,Ystr:ansistring);
    procedure robot_moveZ(Zstr:ansistring);
    procedure robot_release;
    procedure Execute_state_machine_robot;
    procedure Execute_state_machine_manual;

  public
    { Public declarations }
    procedure Send_LCD_Data(line1_str,Line2_str:string);
    procedure Send_LED_Data(L1,L2,L3,L4:byte);
    procedure Send_Status_Request;
    procedure Send_RitePro_Status_Request;
    procedure Turn_On_LED(LED_num:byte);
    procedure Turn_Off_All_LEDs;

    Function Byte_To_HEX(bite : byte):String;
    function Button_Pressed(switch:Tswitch_type):boolean;
    procedure DecodeMessage(MesData : ansistring);

    //-- New functions added to handle P4 DUTs
    procedure Send_P4_Status_Request;
    function is_it_P4: boolean;

  end;

var
  Form1: TForm1;

  Config_File             : text;
  Test_Results_File       : text;
  Local_Test_Results_File : text;

  DLE_Found     : boolean;
  STX_Found     : boolean;
  ETX_Found     : boolean;
  test_mode     : boolean;
  Previous_byte : byte;
  Output_Type   : byte;
  Str2          : String;

  Req_Button_Data_Received : boolean;
  LED_Data_Received        : boolean;
  LCD_Data_Received        : boolean;
  pos_edge_already_sent    : boolean;
  XMIT_LCD_Data            : boolean;
  XMIT_LED_Data            : boolean;

  Task_Num      : word;
  Timeout1_Ctr  : integer;
  Power_Off_Tmr : integer;   //-- Seconds timer.
  Power_On_Tmr  : integer;   //-- Seconds timer.
  Time_Out_Tmr  : integer;   //-- Seconds timer.
  short_delay   : integer;   //-- Seconds timer.
  Flow_Fail_Tmr : integer;   //-- Seconds timer.
  Comm_Error_Tmr: integer;   //-- Seconds timer.
  Response_timer: integer;   //-- Seconds timer.
  xmit_delay1   : integer;   //-- each tick = 100ms
  
  Response_Str  : Ansistring; // MUST BE ANSISTR to prevent errors
  LCD_Line1_Str : string;
  LCD_Line2_Str : string;
  LED_Set1      : byte;
  LED_Set2      : byte;
  LED1,LED2,LED3,LED4 : byte;
  
  LED_HEATER	: boolean;        //-- Led_Set1 bit 0
  LED_VALVE1	: boolean;        //-- Led_Set1 bit 1
  LED_CHECK_SYS	: boolean;        //-- Led_Set1 bit 2
  LED_POOL	: boolean;        //-- Led_Set1 bit 3
  LED_SPA	: boolean;        //-- Led_Set1 bit 4
  LED_FILTER_PUMP : boolean;      //-- Led_Set1 bit 5
  LED_LIGHTS	: boolean;        //-- Led_Set1 bit 6
  LED_AUX1	: boolean;        //-- Led_Set1 bit 7

  LED_AUX2	: boolean;        //-- Led_Set2 bit 0
  LED_SERVICE	: boolean;        //-- Led_Set2 bit 1
  LED_AUX3	: boolean;        //-- Led_Set2 bit 2
  LED_AUX4	: boolean;        //-- Led_Set2 bit 3
  LED_AUX5	: boolean;        //-- Led_Set2 bit 4
  LED_AUX6	: boolean;        //-- Led_Set2 bit 5
  LED_VALVE2	: boolean;        //-- Led_Set2 bit 6
  Display_Blink : boolean;
  packet_found      : boolean;

  days          : array[1..7] of string;
  RC_Buffer     : Array[1..1024] of byte;

  CMD_Found     : boolean;
  CMD_Received  : boolean;
  Str3          : String;
  Byte_Ctr      : word;   //-- number of data byte received so far.
  RC_CTR        : byte;   //-- number of bytes defined in received data stream.
  RC_CMD        : byte;
  RC_CRC        : byte;
  slider_thing  : byte;


  BR_XMIT  : integer;         //-- Button Requests Transmitted
  BR_RCVD  : integer;         //-- Button Responses Received.

  Last_Command_Issued : byte;

  Comports_Configured  : boolean;
  comport1_configured  : boolean;
  COM_Ports_OK         : boolean;
  Communications_Error : boolean;
  Keypad_Request_On    : boolean;
  Capture_State        : boolean;  //-- TRUE=capture button press data, FALSE=ignore

  model_type,
  model_number,
  serial_number        : ansistring;
  initialization_ok    : boolean;
  robot_ACK            : boolean = false;
  robot_NACK           : boolean = false;
  robotcommbusy        : boolean = false;
  robotRxstr           : ansistring;
  robot_timeout        : integer = 0;
  previous_model_type  : ansistring;
  posX,posY,posZ       : real;
  posXstr,posYstr,posZstr : ansistring;
  status_byte,status_byte2,DUT_Model : byte;
  switchnumber         : Tswitch_type;
  SWx                  : ansistring;
  FAIL_TASK_NUM        : integer;
  PASS_TASK_NUM        : integer;
  swloopctr            : integer;
  sw_id,sw_name        : ansistring;
  Retries              : integer;
  button_trial         : integer = 0;
  lcd_test_timeout     : integer = 100; //10 seconds
  robot_move_timeout   : integer = 50; //4 seconds
  robot_initialized    : boolean = false;
  lcdTestVersion       : ansistring;
  lcdTestOnProgress    : boolean = false;
  frameColor                : ansistring;
  counter_pass : integer = 0;
  counter_fail : integer = 0;
  myFile : TextFile;
  text   : string;

  implementation

uses Unit2, Unit3, Unit4, Unit5, Unit7, LCDverify, dbunit, robotpositionunit;

{$R *.DFM}

//------------------------------------------------------------------------------
//--
//------------------------------------------------------------------------------
Procedure TForm1.XDelay(Millisec : word);
Var
        Timeout : TDateTime;
begin
       Timeout := Now + EncodeTime(0,0, Millisec div 1000,Millisec mod 1000);
       while Now < Timeout do;
end;

//------------------------------------------------------------------------------
//-- Delay - Does NOT lock resources.
//------------------------------------------------------------------------------
(*
Procedure TForm1.YDelay(Millisec : word);
Var
        Timeout : TDateTime;
begin
       Timeout := Now + EncodeTime(0,0, Millisec div 1000,Millisec mod 1000);
       while Now < Timeout do Application.ProcessMessages;

end;
*)

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.closebtnClick(Sender: TObject);
begin
     memo1.lines.add('Setting CMD Received := true.');
     CMD_Received := true;

     memo1.lines.add('Setting Last Task to '+IntToStr(LAST_TASK));
     Task_Num     := LAST_TASK;

     memo1.lines.add('Starting Comport1 Close.');
     DisplayComport.Close;
     DisplayProgComport.Close;
     GenIbaseComport.Close;
     GenIIbaseComport.Close;
     RobotComport.Close;

     memo1.lines.add('Starting Application Terminate.');
     Application.Terminate;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
Function TForm1.Byte_To_HEX(bite : byte):String;
Var
   i : byte;
   temp_byte,divisor : byte;
   temp_str  : string;
begin
     temp_str := '';
     divisor := 16;
     for i := 1 to 2 do
       begin
         //-- Shift the highest nibble into the lowest nibble
         temp_byte := (bite div divisor) and $0F;
         case temp_byte of
           0 : temp_str := temp_str + '0';
           1 : temp_str := temp_str + '1';
           2 : temp_str := temp_str + '2';
           3 : temp_str := temp_str + '3';
           4 : temp_str := temp_str + '4';
           5 : temp_str := temp_str + '5';
           6 : temp_str := temp_str + '6';
           7 : temp_str := temp_str + '7';
           8 : temp_str := temp_str + '8';
           9 : temp_str := temp_str + '9';
           10 : temp_str := temp_str + 'A';
           11 : temp_str := temp_str + 'B';
           12 : temp_str := temp_str + 'C';
           13 : temp_str := temp_str + 'D';
           14 : temp_str := temp_str + 'E';
           15 : temp_str := temp_str + 'F';
         end;
         divisor := divisor div 16;
       end;

     Byte_To_HEX := temp_str;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     Task_Num := LAST_TASK;
end;


//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure TForm1.Turn_Off_All_LEDs;
begin
     LED1:=$00;
     LED2:=$00;
     LED3:=$00;
     LED4:=$00;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure TForm1.Turn_On_LED(LED_num:byte);
begin
     if model_type = 'PS4LOCAL' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$02; LED3:=$00; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end
     else if model_type = 'PS4REMOTE' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$00; LED3:=$01; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end
     else if model_type = 'PS8LOCAL' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$02; LED3:=$00; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           12 : begin LED1:=$00; LED2:=$04; LED3:=$00; LED4:=$00; end;
           13 : begin LED1:=$00; LED2:=$08; LED3:=$00; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$10; LED3:=$00; LED4:=$00; end;
           15 : begin LED1:=$00; LED2:=$20; LED3:=$00; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end
     else if model_type = 'PS8REMOTE' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$00; LED3:=$01; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           12 : begin LED1:=$00; LED2:=$04; LED3:=$00; LED4:=$00; end;
           13 : begin LED1:=$00; LED2:=$08; LED3:=$00; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$10; LED3:=$00; LED4:=$00; end;
           15 : begin LED1:=$00; LED2:=$20; LED3:=$00; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end
     else if model_type = 'P4LOCAL' then
       begin
         case LED_num of
           0  : begin LED1:=$00; LED2:=$00; end;
           1  : begin LED1:=$01; LED2:=$00; end;
           2  : begin LED1:=$02; LED2:=$00; end;
           3  : begin LED1:=$04; LED2:=$00; end;
           4  : begin LED1:=$00; LED2:=$02; end;
           5  : begin LED1:=$80; LED2:=$00; end;    //-- AUX1
           6  : begin LED1:=$20; LED2:=$00; end;    //-- Filter
           7  : begin LED1:=$40; LED2:=$00; end;    //-- Lights
           8  : begin LED1:=$00; LED2:=$01; end;    //-- AUX2
           9  : begin LED1:=$08; LED2:=$00; end;    //-- Pool
           10 : begin LED1:=$10; LED2:=$00; end;    //-- Spa
           11 : begin LED1:=$18; LED2:=$00; end;    //-- Pool & Spa
           else begin LED1:=$00; LED2:=$00; end;    //-- No LED's
         end;
       end  
     else if model_type = 'PS16LOCAL' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$02; LED3:=$00; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$00; LED2:=$10; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$00; LED2:=$20; LED3:=$00; LED4:=$00; end;
           12 : begin LED1:=$00; LED2:=$00; LED3:=$02; LED4:=$00; end;
           13 : begin LED1:=$00; LED2:=$00; LED3:=$40; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$00; LED3:=$80; LED4:=$00; end;
           15 : begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$01; end;
           16 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           17 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           18 : begin LED1:=$00; LED2:=$04; LED3:=$00; LED4:=$00; end;
           19 : begin LED1:=$00; LED2:=$08; LED3:=$00; LED4:=$00; end;
           20 : begin LED1:=$00; LED2:=$00; LED3:=$04; LED4:=$00; end;
           21 : begin LED1:=$00; LED2:=$00; LED3:=$08; LED4:=$00; end;
           22 : begin LED1:=$00; LED2:=$00; LED3:=$10; LED4:=$00; end;
           23 : begin LED1:=$00; LED2:=$00; LED3:=$20; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end
     else if model_type = 'PS16REMOTE' then
       begin
         case LED_num of
           0 : begin LED1:=$04; LED2:=$00; LED3:=$00; LED4:=$00; end;
           1 : begin LED1:=$02; LED2:=$00; LED3:=$00; LED4:=$00; end;
           2 : begin LED1:=$00; LED2:=$40; LED3:=$00; LED4:=$00; end;
           3 : begin LED1:=$00; LED2:=$00; LED3:=$01; LED4:=$00; end;
           4 : begin LED1:=$08; LED2:=$00; LED3:=$00; LED4:=$00; end;
           5 : begin LED1:=$10; LED2:=$00; LED3:=$00; LED4:=$00; end;
           6 : begin LED1:=$00; LED2:=$80; LED3:=$00; LED4:=$00; end;
           7 : begin LED1:=$20; LED2:=$00; LED3:=$00; LED4:=$00; end;
           8 : begin LED1:=$40; LED2:=$00; LED3:=$00; LED4:=$00; end;
           9 : begin LED1:=$01; LED2:=$00; LED3:=$00; LED4:=$00; end;
           10 : begin LED1:=$00; LED2:=$10; LED3:=$00; LED4:=$00; end;
           11 : begin LED1:=$00; LED2:=$20; LED3:=$00; LED4:=$00; end;
           12 : begin LED1:=$00; LED2:=$00; LED3:=$02; LED4:=$00; end;
           13 : begin LED1:=$00; LED2:=$00; LED3:=$40; LED4:=$00; end;
           14 : begin LED1:=$00; LED2:=$00; LED3:=$80; LED4:=$00; end;
           15 : begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$01; end;
           16 : begin LED1:=$80; LED2:=$00; LED3:=$00; LED4:=$00; end;
           17 : begin LED1:=$00; LED2:=$01; LED3:=$00; LED4:=$00; end;
           18 : begin LED1:=$00; LED2:=$04; LED3:=$00; LED4:=$00; end;
           19 : begin LED1:=$00; LED2:=$08; LED3:=$00; LED4:=$00; end;
           20 : begin LED1:=$00; LED2:=$00; LED3:=$04; LED4:=$00; end;
           21 : begin LED1:=$00; LED2:=$00; LED3:=$08; LED4:=$00; end;
           22 : begin LED1:=$00; LED2:=$00; LED3:=$10; LED4:=$00; end;
           23 : begin LED1:=$00; LED2:=$00; LED3:=$20; LED4:=$00; end;
           else begin LED1:=$00; LED2:=$00; LED3:=$00; LED4:=$00; end;
         end;
       end;

end;

//-----------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------
function TForm1.Button_Pressed(switch:Tswitch_type):boolean;
begin
     result := false;

     if model_type = 'PS4LOCAL' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button
    (*
           SW8 : if byte(Response_Str[7]) = $02 then result := true;
           SW9 : if byte(Response_Str[7]) = $02 then result := true;
           SW10 : if byte(Response_Str[7]) = $02 then result := true;
           SW11 : if byte(Response_Str[7]) = $02 then result := true;
           SW12 : if byte(Response_Str[6]) = $02 then result := true;
    *)
           SW13 : if byte(Response_Str[6]) = $02 then result := true;     //-- 'AUX1' button
    (*
           SW14 : if byte(Response_Str[6]) = $08 then result := true;
           SW15 : if byte(Response_Str[7]) = $02 then result := true;
           SW16 : if byte(Response_Str[7]) = $02 then result := true;
           SW17 : if byte(Response_Str[7]) = $02 then result := true;
           SW18 : if byte(Response_Str[7]) = $02 then result := true;
           SW19 : if byte(Response_Str[6]) = $10 then result := true;
    *)
           SW20 : if byte(Response_Str[6]) = $04 then result := true;      //-- 'AUX2' button
//--           SW21 : if byte(Response_Str[6]) = $40 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if model_type = 'PS4REMOTE' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button
    (*
           SW8 : if byte(Response_Str[7]) = $02 then result := true;
           SW9 : if byte(Response_Str[7]) = $02 then result := true;
           SW10 : if byte(Response_Str[7]) = $02 then result := true;
           SW11 : if byte(Response_Str[7]) = $02 then result := true;
           SW12 : if byte(Response_Str[6]) = $02 then result := true;
    *)
           SW13 : if byte(Response_Str[6]) = $02 then result := true;
    (*
           SW14 : if byte(Response_Str[6]) = $08 then result := true;
           SW15 : if byte(Response_Str[7]) = $02 then result := true;
           SW16 : if byte(Response_Str[7]) = $02 then result := true;
           SW17 : if byte(Response_Str[7]) = $02 then result := true;
           SW18 : if byte(Response_Str[7]) = $02 then result := true;
           SW19 : if byte(Response_Str[6]) = $10 then result := true;
    *)
           SW20 : if byte(Response_Str[6]) = $04 then result := true;
//--           SW21 : if byte(Response_Str[6]) = $40 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if model_type = 'PS8LOCAL' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button
    (*
           SW8 : if byte(Response_Str[7]) = $02 then result := true;
           SW9 : if byte(Response_Str[7]) = $02 then result := true;
           SW10 : if byte(Response_Str[7]) = $02 then result := true;
           SW11 : if byte(Response_Str[7]) = $02 then result := true;
    *)
           SW12 : if byte(Response_Str[6]) = $02 then result := true;
           SW13 : if byte(Response_Str[6]) = $04 then result := true;
           SW14 : if byte(Response_Str[6]) = $08 then result := true;
    (*
           SW15 : if byte(Response_Str[7]) = $02 then result := true;
           SW16 : if byte(Response_Str[7]) = $02 then result := true;
           SW17 : if byte(Response_Str[7]) = $02 then result := true;
           SW18 : if byte(Response_Str[7]) = $02 then result := true;
    *)
           SW19 : if byte(Response_Str[6]) = $10 then result := true;
           SW20 : if byte(Response_Str[6]) = $20 then result := true;
           SW21 : if byte(Response_Str[6]) = $40 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if model_type = 'PS8REMOTE' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button
    (*
           SW8 : if byte(Response_Str[7]) = $02 then result := true;
           SW9 : if byte(Response_Str[7]) = $02 then result := true;
           SW10 : if byte(Response_Str[7]) = $02 then result := true;
           SW11 : if byte(Response_Str[7]) = $02 then result := true;
    *)
           SW12 : if byte(Response_Str[6]) = $02 then result := true;
           SW13 : if byte(Response_Str[6]) = $04 then result := true;
           SW14 : if byte(Response_Str[6]) = $08 then result := true;
    (*
           SW15 : if byte(Response_Str[7]) = $02 then result := true;
           SW16 : if byte(Response_Str[7]) = $02 then result := true;
           SW17 : if byte(Response_Str[7]) = $02 then result := true;
           SW18 : if byte(Response_Str[7]) = $02 then result := true;
    *)
           SW19 : if byte(Response_Str[6]) = $10 then result := true;
           SW20 : if byte(Response_Str[6]) = $20 then result := true;
           SW21 : if byte(Response_Str[6]) = $40 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if model_type = 'PS16LOCAL' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button

           SW8 : if byte(Response_Str[6]) = $02 then result := true;
           SW9 : if byte(Response_Str[6]) = $04 then result := true;
           SW10 : if byte(Response_Str[6]) = $08 then result := true;
           SW11 : if byte(Response_Str[6]) = $10 then result := true;
           SW12 : if byte(Response_Str[6]) = $20 then result := true;
           SW13 : if byte(Response_Str[6]) = $40 then result := true;
           SW14 : if byte(Response_Str[6]) = $80 then result := true;

           SW15 : if byte(Response_Str[7]) = $08 then result := true;
           SW16 : if byte(Response_Str[7]) = $10 then result := true;
           SW17 : if byte(Response_Str[7]) = $20 then result := true;
           SW18 : if byte(Response_Str[7]) = $40 then result := true;
           SW19 : if byte(Response_Str[7]) = $80 then result := true;
           SW20 : if byte(Response_Str[8]) = $01 then result := true;
           SW21 : if byte(Response_Str[8]) = $02 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if is_it_p4 then
       begin
// memo1.Lines.Add(Response_Str[5]+Response_Str[6]); //-- DEBUG CODE
         case switch of
           SW1  : if byte(Response_Str[5]) = $01 then result := true;
           SW2  : if byte(Response_Str[5]) = $02 then result := true;
           SW3  : if byte(Response_Str[5]) = $04 then result := true;
           SW4  : if byte(Response_Str[5]) = $08 then result := true;
           SW5  : if byte(Response_Str[5]) = $10 then result := true;
           SW6  : if byte(Response_Str[5]) = $20 then result := true;
           SW7  : if byte(Response_Str[5]) = $40 then result := true;
           SW8  : if byte(Response_Str[5]) = $80 then result := true;
           SW9  : if byte(Response_Str[6]) = $01 then result := true;
           SW10 : if byte(Response_Str[6]) = $04 then result := true;     //-- 'AUX2' button
           SW11 : if byte(Response_Str[6]) = $02 then result := true;     //-- 'AUX1' button
         end;
       end
     else if model_type = 'PS16REMOTE' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'SERVICE' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'POOL/SPA' button
           SW3 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'FILTER' button
           SW4 : if byte(Response_Str[6]) = $01 then result := true;      //-- 'LIGHTS' button
           SW5 : if byte(Response_Str[7]) = $04 then result := true;      //-- 'HEATER1' button
           SW6 : if byte(Response_Str[7]) = $01 then result := true;      //-- 'VALVE3' button
           SW7 : if byte(Response_Str[7]) = $02 then result := true;      //-- 'VALVE4' button

           SW8 : if byte(Response_Str[6]) = $02 then result := true;
           SW9 : if byte(Response_Str[6]) = $04 then result := true;
           SW10 : if byte(Response_Str[6]) = $08 then result := true;
           SW11 : if byte(Response_Str[6]) = $10 then result := true;
           SW12 : if byte(Response_Str[6]) = $20 then result := true;
           SW13 : if byte(Response_Str[6]) = $40 then result := true;
           SW14 : if byte(Response_Str[6]) = $80 then result := true;

           SW15 : if byte(Response_Str[7]) = $08 then result := true;
           SW16 : if byte(Response_Str[7]) = $10 then result := true;
           SW17 : if byte(Response_Str[7]) = $20 then result := true;
           SW18 : if byte(Response_Str[7]) = $40 then result := true;
           SW19 : if byte(Response_Str[7]) = $80 then result := true;
           SW20 : if byte(Response_Str[8]) = $01 then result := true;
           SW21 : if byte(Response_Str[8]) = $02 then result := true;

           SW22 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button
           SW23 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW24 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'MENU' button
           SW25 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW26 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
         end;
       end
     else if model_type = 'RITEPRO' then
       begin
         case switch of
           SW1 : if byte(Response_Str[5]) = $80 then result := true;      //-- 'RUN/STOP' button
           SW2 : if byte(Response_Str[5]) = $40 then result := true;      //-- 'SUPER CHLORINATE' button
           SW3 : if byte(Response_Str[5]) = $08 then result := true;      //-- 'INFO' button
           SW4 : if byte(Response_Str[5]) = $02 then result := true;      //-- 'SETTINGS' button
           SW5 : if byte(Response_Str[5]) = $20 then result := true;      //-- '+' button
           SW6 : if byte(Response_Str[5]) = $01 then result := true;      //-- '>' button
           SW7 : if byte(Response_Str[5]) = $10 then result := true;      //-- '-' button
           SW8 : if byte(Response_Str[5]) = $04 then result := true;      //-- '<' button

         end;
       end


end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
function TForm1.is_it_P4: boolean;
begin
   result := (model_type = 'P4LOCAL') or (model_type = 'P4REMOTE');
end;


//-----------------------------------------------------------------------------------------
//-- This routine initiates the testing.
//-- Testing will begin when 'Testing_enabled' parameter is set true.
//-- Actual testing is performed by the 'Execute_state_machine_manual' or
//-- 'Execute_state_machine_robot'.  These routines are called by the Timer2 event.
//-----------------------------------------------------------------------------------------
procedure TForm1.StartClick(Sender: TObject);
begin
   Start.enabled := false;

     //-- Display the barcode window.
     barcode.Set_Display_Type(2);

     //-- Display the barcode window.
     if barcode.showmodal <> mrOk then
       begin
         memo1.Lines.add('Cancel pressed');
         Start.enabled := true;
         Start.SetFocus;
         Keypad_Request_On := false;
         Capture_State     := false;
         exit;
       end;

     //-- Check for valid model number from barcode scan
     Model_Number  := trim(uppercase(barcode.Get_Model_Number));
     Serial_Number := trim(uppercase(barcode.Get_Serial_Number));

     if (Model_Number='') or (Serial_Number='') then
       begin
         Showmessage('Invalid barcode scan.  Unable to test.');
         Start.enabled := true;
         Start.SetFocus;
         Keypad_Request_On := false;
         Capture_State     := false;
         exit;
       end;

     if Not(Configuration.valid_model(Model_Number)) then
       begin
         Showmessage('Unknown model type.  Unable to test.');
         Start.enabled := true;
         Start.SetFocus;
         Keypad_Request_On := false;
         Capture_State     := false;
         exit;
       end;

     //-- Get the unit type.  This tells us if we need to test a PS4 local, PS4 remote, PS8 local,......
     //--   nullstring   = UNKNOWN
     //--   PS4LOCAL     = PS4 local
     //--   PS4REMOTE    = PS4 remote
     //--   PS4REMOTERF  = PS4 RF
     //--
     //--   PS8LOCAL     = PS8 local
     //--   PS8REMOTE    = PS8 remote
     //--   PS8REMOTERF  = PS8 RF
     //--
     //--   PS16LOCAL    = PS16 local
     //--   PS16REMOTE   = PS16 remote
     //--   PS16REMOTERF = PS16 RF
     //--
     //--   PS32LOCAL    = PS32 local
     //--   PS32REMOTE   = PS32 remote
     //--   PS32REMOTERF = PS32 RF
     //--
     //--   P4LOCAL      = P4 Local, uses separate communication functions

     model_type := Configuration.Get_Unit_Type(Model_Number);

     if MessageDlg('Place unit on fixture, press OK to continue testing',mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
       begin
         memo1.Lines.add('Cancel pressed');
         Start.enabled := true;
         Start.SetFocus;
         Keypad_Request_On := false;
         Capture_State     := false;
         exit;
       end;

     //-- Load the proper model_type position table if it has changed
     if previous_model_type <> model_type then
       begin
         //-- exit if the position table is not found
         if not(robotposition.load_position_table(Model_Number)) then
           begin
             memo1.Lines.add('No position table defined for '+Model_Number);
             Start.enabled := true;
             Start.SetFocus;
             Keypad_Request_On := false;
             Capture_State     := false;
             exit;
           end;

         previous_model_type := model_type;
       end;

     Memo1.Clear;
     memo1.Lines.add('TESTING');
     memo1.Lines.add('model#  : '+model_number);
     memo1.Lines.add('serial# : '+Serial_number);


     Timeout1_Ctr     := 5;
     Symptom.Caption  := '';
     Task_Num         := 0;
     status_byte      := 0;
     DUT_Model        := 0;
     PassFail.Color   := clYellow;
     PassFail.Caption := 'TESTING';

     //-- enable the test state machine.
     Testing_enabled := true;
end;

//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
procedure TForm1.Execute_state_machine_manual;
Var
   dummy_str : string;
   status_byte,status_byte2,DUT_Model : byte;
begin
       if not(Testing_enabled) then exit;

       StaticText1.Caption := IntToStr(Task_Num);

       case Task_Num of
         0 : begin  //-- Initialization
               //-- begin requesting button data from keypad.
               Keypad_Request_On := true;

               Retries  := 0;   //-- needed for task# 6

               Task_Num := 1;
             end;

         1 : begin  //-- Check Status of DUT
               Capture_State  := true;
               Response_timer := 3;
               packet_found   := false;
               Task_Num       := 2;

               if model_type = 'RITEPRO' then
                 Send_RitePro_Status_Request
               else
                 Send_Status_Request;
             end;

         2 : begin  //-- wait for response
                if packet_found then
                  begin
                    //-- Check Version number.
                    Capture_State := false;

                    dummy_str := copy(Response_Str,5,2) + '.' + copy(Response_Str,7,2);

                    if Configuration.Get_Version_Number(model_number) = dummy_str then
                      begin
                        memo1.Lines.add('Firmware ver : '+dummy_str);
                        Task_Num := 3;
                      end
                    else
                      begin
                        Inc(Retries);
                        if Retries<3 then
                          begin
                            Task_Num := 1;
                          end
                        else
                          begin
                            memo1.Lines.add('Wrong Firmware Version : '+dummy_str);
                            memo1.Lines.add('Expected '+Configuration.Get_Version_Number(model_number));
                            Task_Num := 5260;
                          end;

                      end;
                  end
                else if Response_timer=0 then
                  begin
                    Inc(Retries);
                    if Retries<3 then
                      begin
                        Task_Num := 1;
                      end
                    else
                      begin
                        //-- No response from DUT.
                        Task_Num := 4000;
                      end;
                  end;
             end;

         3 : begin
               if model_type = 'RITEPRO' then
                 begin
                   Task_Num := 400;
                 end
               else
                 begin
                   //-- Check to see if this device has already been programmed with it's model type.
                   status_byte := byte(Response_Str[10]);

                   //-- Check the Valid Terminal Config bit. 0 = unprogrammed.
                   status_byte2 := status_byte and $08;

                   //-- Determine what type of display has been programmed.
                   DUT_Model    := status_byte and $70;

                   //-- If this device is virgin, then continue testing.
                   if status_byte2 = 0 then Task_Num := 5

                   else
                     //-- If the device is already programmed but just being retested, continue testing.
                     //-- The DUT's 'model type' must match the barcode scan type.
                     begin
                       case DUT_Model of
                         $20 : if model_type = 'PS4LOCAL'   then Task_Num := 4 else Task_Num := 5270;
                         $30 : if model_type = 'PS4REMOTE'  then Task_Num := 4 else Task_Num := 5270;
                         $40 : if model_type = 'PS8LOCAL'   then Task_Num := 4 else Task_Num := 5270;
                         $50 : if model_type = 'PS8REMOTE'  then Task_Num := 4 else Task_Num := 5270;
                         $60 : if model_type = 'PS16LOCAL'  then Task_Num := 4 else Task_Num := 5270;
                         $70 : if model_type = 'PS16REMOTE' then Task_Num := 4 else Task_Num := 5270;
                       end;
                     end;
                 end;
             end;

         4 : begin
               case DUT_Model of
                 $20 : memo1.lines.add('Device already programmed as PS4LOCAL');
                 $30 : memo1.lines.add('Device already programmed as PS4REMOTE');
                 $40 : memo1.lines.add('Device already programmed as PS8LOCAL');
                 $50 : memo1.lines.add('Device already programmed as PS8REMOTE');
                 $60 : memo1.lines.add('Device already programmed as PS16LOCAL');
                 $70 : memo1.lines.add('Device already programmed as PS16REMOTE');
               end;

               //-- skip programming task.
               Task_Num := 6;
             end;


         5 : begin  //-- program device type (local/remote, PS4/PS8/PS16)
               Capture_State  := false;
               Send_Enter_Testmode_Command;
               XDelay(100);
               Program_Device_Type;
               XDelay(4000);

               Task_Num := 6;
             end;

         6 : begin  //-- Check Display
                LCD_Line1_Str := ' LCD Display Check  ';
                LCD_Line2_Str := ' Press PASS or FAIL ';
                XMIT_LCD_DATA := true;

                Response_timer := 2;
                Task_Num := 7;
             end;

         7 : begin  //-- Wait a couple of seconds
               if Response_timer=0 then Task_Num := 8;
             end;

         8 : begin  //-- Check Display
               if  LCDverifyDlg.Showmodal <> mrOk then
                 begin
                   memo1.Lines.add('LCD Display Failed');
                   Task_Num := 5280;
                 end
               else
                 Task_Num := 10;

             end;


         10 : begin    //-- Test SW1
                Capture_State  := true;

                if (model_type = 'PS4LOCAL') or (model_type = 'PS8LOCAL') or (model_type = 'PS16LOCAL') then
                  begin
                    LCD_Line1_Str := '    PRESS SERVICE  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS SERVICE');
                  end
                else if (model_type = 'PS4REMOTE') or (model_type = 'PS8REMOTE') or (model_type = 'PS16REMOTE') then
                  begin
                    LCD_Line1_Str := '   PRESS SYSTEM     ';
                    LCD_Line2_Str := '      BUTTON        ';
                    memo1.Lines.add('PRESS SYSTEM');
                  end;

                XMIT_LCD_DATA := true;

                Turn_On_LED(3);
                XMIT_LED_DATA := true;

                Task_Num       := 11;
                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         11 : begin
                //-- Wait for operator to Press SW1
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW1) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 20;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5000;
                      end
                    else
                      begin

                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS8LOCAL') or (model_type = 'PS16LOCAL') then
                          begin
                            LCD_Line1_Str := '    PRESS SERVICE  ';
                            LCD_Line2_Str := '        BUTTON    ';
                            memo1.Lines.add('PRESS SERVICE');
                          end
                        else if (model_type = 'PS4REMOTE') or (model_type = 'PS8REMOTE') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '   PRESS SYSTEM     ';
                            LCD_Line2_Str := '      BUTTON        ';
                            memo1.Lines.add('PRESS SYSTEM');
                          end;
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5000;
                  end;
              end;

         20 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS POOL/SPA');

                LCD_Line1_Str := '    PRESS POOL/SPA  ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(5);
                XMIT_LED_DATA := true;

                Task_Num := 21;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         21 : begin
                //-- Wait for operator to Press SW2
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW2) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 30;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5010;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '    PRESS POOL/SPA  ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5010;
                  end;

              end;

         30 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS FILTER');

                LCD_Line1_Str := '     PRESS FILTER   ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(7);
                XMIT_LED_DATA := true;

                Task_Num := 31;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;
         31 : begin
                //-- Wait for operator to Press SW3
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW3) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 40;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5020;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '     PRESS FILTER   ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5020;
                  end;

              end;

         40 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS LIGHTS');

                LCD_Line1_Str := '     PRESS LIGHTS   ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(8);
                XMIT_LED_DATA := true;

                Task_Num := 41;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;
         41 : begin
                //-- Wait for operator to Press SW4
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW4) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 50;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5030;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '     PRESS LIGHTS   ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5030;
                  end;

              end;

         50 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS HEATER1');

                LCD_Line1_Str := '    PRESS HEATER1   ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(9);
                XMIT_LED_DATA := true;

                Task_Num := 51;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         51 : begin
                //-- Wait for operator to Press SW5
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW5) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 60;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5040;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '    PRESS HEATER1   ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5040;
                  end;

              end;

         60 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS VALVE3');

                LCD_Line1_Str := '     PRESS VALVE3   ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(1);
                XMIT_LED_DATA := true;

                Task_Num := 61;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;
         61 : begin
                //-- Wait for operator to Press SW6
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW6) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 70;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5050;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '     PRESS VALVE3   ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5050;
                  end;

              end;

         70 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS VALVE4');

                LCD_Line1_Str := '     PRESS VALVE4   ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(2);
                XMIT_LED_DATA := true;

                Task_Num := 71;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         71 : begin
                //-- Wait for operator to Press SW7
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW7) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then Task_Num := 130
                        else if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then Task_Num := 120
                        else Task_Num := 80;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5060;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '     PRESS VALVE4   ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5060;
                  end;

              end;

         80 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX1');

                LCD_Line1_Str := '      PRESS AUX1  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(16);
                XMIT_LED_DATA := true;

                Task_Num := 81;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         81 : begin
                //-- Wait for operator to Press SW8
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW8) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 90;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5070;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX2';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5070;
                  end;

              end;

         90 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX2');

                LCD_Line1_Str := '      PRESS AUX2  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(17);
                XMIT_LED_DATA := true;

                Task_Num := 91;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         91 : begin
                //-- Wait for operator to Press SW9
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW9) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 100;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5080;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX2';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5080;
                  end;

              end;

         100 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX3');

                LCD_Line1_Str := '      PRESS AUX3  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(18);
                XMIT_LED_DATA := true;

                Task_Num := 101;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         101 : begin
                //-- Wait for operator to Press SW10
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW10) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 110;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5090;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX3';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5090;
                  end;

              end;

         110 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX4');

                LCD_Line1_Str := '      PRESS AUX4  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(19);
                XMIT_LED_DATA := true;

                Task_Num := 111;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         111 : begin
                //-- Wait for operator to Press SW11
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW11) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 120;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5100;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX4';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5100;
                  end;

              end;

        120 : begin
                //-- Send Text display to Control Pad

                if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    memo1.Lines.add('PRESS AUX1');
                    LCD_Line1_Str := '      PRESS AUX1  ';
                    LCD_Line2_Str := '        BUTTON    ';
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    memo1.Lines.add('PRESS AUX5');
                    LCD_Line1_Str := '      PRESS AUX5  ';
                    LCD_Line2_Str := '        BUTTON    ';
                  end;

                XMIT_LCD_DATA := true;

                Turn_On_LED(10);
                XMIT_LED_DATA := true;


                Task_Num := 121;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         121 : begin
                //-- Wait for operator to Press SW12
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW12) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 130;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5110;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX1';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX5';
                          end;

                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5110;
                  end;

              end;

         130 : begin
                //-- Send Text display to Control Pad
                if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX1  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX1');
                  end
                else if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX2  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX2');
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX6  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX6');
                  end;


                XMIT_LCD_DATA := true;

                Turn_On_LED(11);
                XMIT_LED_DATA := true;


                Task_Num := 131;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         131 : begin
                //-- Wait for operator to Press SW13
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW13) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then Task_Num := 200
                        else Task_Num := 140;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5120;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX1';
                          end
                        else if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX2';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX6';
                          end;

                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5120;
                  end;

              end;

         140 : begin
                //-- Send Text display to Control Pad
                if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX3  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX3');
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX7  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX7');
                  end;

                XMIT_LCD_DATA := true;

                Turn_On_LED(12);
                XMIT_LED_DATA := true;


                Task_Num := 141;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         141 : begin
                //-- Wait for operator to Press SW14
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW14) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then Task_Num := 190
                        else Task_Num := 150;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5130;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX3';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX7';
                          end;

                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5130;
                  end;

              end;

         150 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX8');

                LCD_Line1_Str := '      PRESS AUX8  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(20);
                XMIT_LED_DATA := true;

                Task_Num := 151;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         151 : begin
                //-- Wait for operator to Press SW15
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW15) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 160;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5140;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX8';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5140;
                  end;

              end;

         160 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX9');

                LCD_Line1_Str := '      PRESS AUX9  ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(21);
                XMIT_LED_DATA := true;

                Task_Num := 161;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         161 : begin
                //-- Wait for operator to Press SW16
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW16) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 170;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5150;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX9';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5150;
                  end;

              end;

         170 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX10');

                LCD_Line1_Str := '      PRESS AUX10 ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(22);
                XMIT_LED_DATA := true;

                Task_Num := 171;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         171 : begin
                //-- Wait for operator to Press SW17
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW17) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 180;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5160;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX10';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                 end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5160;
                  end;

              end;

         180 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS AUX11');

                LCD_Line1_Str := '      PRESS AUX11 ';
                LCD_Line2_Str := '        BUTTON    ';
                XMIT_LCD_DATA := true;

                Turn_On_LED(23);
                XMIT_LED_DATA := true;

                Task_Num := 181;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         181 : begin
                //-- Wait for operator to Press SW18
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW18) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 190;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5170;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS AUX11';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5170;
                  end;

              end;

         190 : begin
                //-- Send Text display to Control Pad
                if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    memo1.Lines.add('PRESS AUX4');
                    LCD_Line1_Str := '      PRESS AUX4  ';
                    LCD_Line2_Str := '        BUTTON    ';
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    memo1.Lines.add('PRESS AUX12');
                    LCD_Line1_Str := '      PRESS AUX12 ';
                    LCD_Line2_Str := '        BUTTON    ';
                  end;

                XMIT_LCD_DATA := true;

                Turn_On_LED(13);
                XMIT_LED_DATA := true;

                Task_Num := 191;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         191 : begin
                //-- Wait for operator to Press SW19
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW19) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 200;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5180;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX4';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX12';
                          end;
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5180;
                  end;

              end;

         200 : begin
                //-- Send Text display to Control Pad
                if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX2  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX2');
                  end
                else if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX5  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX5');
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX13 ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX13');
                  end;

                XMIT_LCD_DATA := true;

                Turn_On_LED(14);
                XMIT_LED_DATA := true;

                Task_Num := 201;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         201 : begin
                //-- Wait for operator to Press SW20
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW20) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then Task_Num := 220
                        else Task_Num := 210;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5190;
                      end
                    else
                      begin
                                //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS4LOCAL') or (model_type = 'PS4REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX2';
                          end
                        else if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX5';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX13';
                          end;

                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5190;
                  end;

              end;

         210 : begin
                //-- Send Text display to Control Pad
                if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX6  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX6');
                  end
                else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                  begin
                    LCD_Line1_Str := '      PRESS AUX14  ';
                    LCD_Line2_Str := '        BUTTON    ';
                    memo1.Lines.add('PRESS AUX14');
                  end;
                XMIT_LCD_DATA := true;

                Turn_On_LED(15);
                XMIT_LED_DATA := true;

                Task_Num := 211;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         211 : begin
                //-- Wait for operator to Press SW21
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW21) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 220;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5200;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        if (model_type = 'PS8LOCAL') or (model_type = 'PS8REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX6';
                          end
                        else if (model_type = 'PS16LOCAL') or (model_type = 'PS16REMOTE') then
                          begin
                            LCD_Line1_Str := '      ERROR';
                            LCD_Line2_Str := '    PRESS AUX14';
                          end;
                       XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5200;
                  end;

              end;

         220 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS <');

                LCD_Line1_Str := '      PRESS <';
                LCD_Line2_Str := '      BUTTON';
                XMIT_LCD_DATA := true;

                Turn_On_LED(0);
                XMIT_LED_DATA := true;

                Task_Num := 221;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
             end;

         221 : begin
                //-- Wait for operator to Press SW22
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW22) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 230;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5210;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '     PRESS <';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5210;
                  end;

              end;

         230 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS -');

                LCD_Line1_Str := '      PRESS -';
                LCD_Line2_Str := '      BUTTON';
                XMIT_LCD_DATA := true;

                Task_Num := 231;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         231 : begin
                //-- Wait for operator to Press SW23
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW23) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 240;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5220;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '     PRESS -';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                 end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5220;
                  end;

              end;

         240 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS MENU');

                LCD_Line1_Str := '      PRESS MENU';
                LCD_Line2_Str := '        BUTTON';
                XMIT_LCD_DATA := true;

                Task_Num := 241;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         241 : begin
                //-- Wait for operator to Press SW24
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW24) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 250;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5230;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '    PRESS MENU';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5230;
                  end;

              end;

          250 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS +');

                LCD_Line1_Str := '      PRESS +';
                LCD_Line2_Str := '      BUTTON';
                XMIT_LCD_DATA := true;

                Task_Num := 251;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         251 : begin
                //-- Wait for operator to Press SW25

                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW25) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 260;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5240;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '     PRESS +';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5240;
                  end;

              end;

          260 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS >');

                LCD_Line1_Str := '      PRESS >';
                LCD_Line2_Str := '      BUTTON';
                XMIT_LCD_DATA := true;

                Task_Num := 261;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         261 : begin
                //-- Wait for operator to Press SW26
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW26) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 270;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5250;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      ERROR';
                        LCD_Line2_Str := '     PRESS >';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5250;
                  end;

              end;

         270 : begin
                 Task_Num := 3000;
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;
                 memo1.lines.add('PASS');
                 Symptom.caption := 'PASS';

                 PassFail.Color   := clLime;
                 PassFail.Caption := 'PASS';

                 LCD_Line1_Str := 'PASS PASS PASS PASS';
                 LCD_Line2_Str := 'PASS PASS PASS PASS';
                 XMIT_LCD_DATA := true;

                 Write_Result('PASS',model_number,serial_number);
               end;




//-----------------------------------------------------------------------------
//-- RITE PRO Display Testing
//-----------------------------------------------------------------------------

         400 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS RUN/STOP');

                LCD_Line1_Str := '    PRESS RUN/STOP  ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 410;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         410: begin
                //-- Wait for operator to Press SW1
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW1) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 420;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5000;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '    PRESS RUN/STOP  ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         420 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS SUPER CHLORINATE');

                LCD_Line1_Str := '   PRESS SUPER     ';
                LCD_Line2_Str := 'CHLORINATE BUTTON  ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 430;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         430: begin
                //-- Wait for operator to Press SW2
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW2) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 440;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5010;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '   PRESS SUPER     ';
                        LCD_Line2_Str := 'CHLORINATE BUTTON  ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         440 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS INFO');

                LCD_Line1_Str := '      PRESS INFO    ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 450;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         450: begin
                //-- Wait for operator to Press SW3
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW3) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 460;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5020;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '      PRESS INFO    ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         460 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS SETTINGS');

                LCD_Line1_Str := '    PRESS SETTINGS  ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 470;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         470: begin
                //-- Wait for operator to Press SW4
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW4) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 480;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5030;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '    PRESS SETTINGS  ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 5010;
                  end;

              end;


         480 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS +');

                LCD_Line1_Str := '        PRESS +     ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 490;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         490: begin
                //-- Wait for operator to Press SW5
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW5) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 500;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5040;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '        PRESS +     ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         500 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS >');

                LCD_Line1_Str := '        PRESS >     ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 510;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         510: begin
                //-- Wait for operator to Press SW6
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW6) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 520;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5050;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '        PRESS >     ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         520 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS -');

                LCD_Line1_Str := '        PRESS -     ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 530;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         530: begin
                //-- Wait for operator to Press SW7
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW7) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 540;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5060;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '        PRESS -     ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         540 : begin
                //-- Send Text display to Control Pad
                memo1.Lines.add('PRESS <');

                LCD_Line1_Str := '        PRESS <     ';
                LCD_Line2_Str := '        BUTTON      ';
                XMIT_LCD_DATA := true;

 //--               Turn_On_LED(5);
 //--               XMIT_LED_DATA := true;

                Task_Num := 550;

                Capture_State  := true;
                Response_timer := 10;
                packet_found   := false;
                Retries        := 0;
              end;

         550: begin
                //-- Wait for operator to Press SW8
                if packet_found then
                  begin
                    Capture_State := false;

                    if Button_Pressed(SW8) then
                      begin
                        //-- Correct button was pressed.  Go to next task.
                        Task_Num := 560;
                      end
                    else if Retries = 3 then
                      begin
                        //-- Wrong button was pressed a 2nd time.  Fail this device and exit.
                        Task_Num := 5070;
                      end
                    else
                      begin
                        //-- Wrong button pressed.  Send message to operator.
                        LCD_Line1_Str := '        PRESS <     ';
                        LCD_Line2_Str := '        BUTTON      ';
                        XMIT_LCD_DATA := true;

                        Response_timer := 10;
                        Capture_State  := true;
                        packet_found   := false;

                        inc(Retries);
                      end;
                  end
                else if Response_timer=0 then
                  begin
                    //-- No response from operator.
                    Task_Num := 4000;
                  end;

              end;

         560: begin
                 Task_Num := 3000;
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;
                 memo1.lines.add('PASS');
                 Symptom.caption := 'PASS';

                 PassFail.Color   := clLime;
                 PassFail.Caption := 'PASS';

                 LCD_Line1_Str := 'PASS PASS PASS PASS';
                 LCD_Line2_Str := 'PASS PASS PASS PASS';
                 XMIT_LCD_DATA := true;

                 Write_Result('PASS',model_number,serial_number);
              end;


         3000: begin

                 //-- Short delay to keep message on LCD disply.
                 if Response_timer=0 then Task_Num  := LAST_TASK;

               end;
         4000: begin
                 memo1.lines.add('No Response from Control Pad.  Fail.');
                 Symptom.caption  := 'FUNC TEST 1';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 1',model_number,serial_number);
               end;
         5000: begin
                 memo1.lines.add('ERROR:SW1');
                 Symptom.caption  := 'FUNC TEST 2';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num         := 6000;
                 Write_Result('FUNC TEST 2',model_number,serial_number);
               end;
         5010: begin
                 memo1.lines.add('ERROR:SW2');
                 Symptom.caption := 'FUNCTIONAL TEST 3';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 3',model_number,serial_number);
               end;
         5020: begin
                 memo1.lines.add('ERROR:SW3');
                 Symptom.caption := 'FUNCTIONAL TEST 4';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 4',model_number,serial_number);
               end;
         5030: begin
                 memo1.lines.add('ERROR:SW4');
                 Symptom.caption := 'FUNCTIONAL TEST 5';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 5',model_number,serial_number);
               end;
         5040: begin
                 memo1.lines.add('ERROR:SW5');
                 Symptom.caption := 'FUNCTIONAL TEST 6';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 6',model_number,serial_number);
               end;
         5050: begin
                 memo1.lines.add('ERROR:SW6');
                 Symptom.caption := 'FUNCTIONAL TEST 7';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 7',model_number,serial_number);
               end;
         5060: begin
                 memo1.lines.add('ERROR:SW7');
                 Symptom.caption := 'FUNCTIONAL TEST 8';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 8',model_number,serial_number);
               end;
         5070: begin
                 memo1.lines.add('ERROR:SW8');
                 Symptom.caption := 'FUNCTIONAL TEST 9';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 9',model_number,serial_number);
               end;
         5080: begin
                 memo1.lines.add('ERROR:SW9');
                 Symptom.caption := 'FUNCTIONAL TEST 10';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 10',model_number,serial_number);
               end;
         5090: begin
                 memo1.lines.add('ERROR:SW10');
                 Symptom.caption := 'FUNCTIONAL TEST 11';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 11',model_number,serial_number);
               end;
         5100: begin
                 memo1.lines.add('ERROR:SW11');
                 Symptom.caption := 'FUNCTIONAL TEST 12';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 12',model_number,serial_number);
               end;
         5110: begin
                 memo1.lines.add('ERROR:SW12');
                 Symptom.caption := 'FUNCTIONAL TEST 13';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 13',model_number,serial_number);
               end;
         5120: begin
                 memo1.lines.add('ERROR:SW13');
                 Symptom.caption := 'FUNCTIONAL TEST 14';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 14',model_number,serial_number);
               end;
         5130: begin
                 memo1.lines.add('ERROR:SW14');
                 Symptom.caption := 'FUNCTIONAL TEST 15';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 15',model_number,serial_number);
               end;
         5140: begin
                 memo1.lines.add('ERROR:SW15');
                 Symptom.caption := 'FUNCTIONAL TEST 16';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 16',model_number,serial_number);
               end;
         5150: begin
                 memo1.lines.add('ERROR:SW16');
                 Symptom.caption := 'FUNCTIONAL TEST 17';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 17',model_number,serial_number);
               end;
         5160: begin
                 memo1.lines.add('ERROR:SW17');
                 Symptom.caption := 'FUNCTIONAL TEST 18';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 18',model_number,serial_number);
               end;
         5170: begin
                 memo1.lines.add('ERROR:SW18');
                 Symptom.caption := 'FUNCTIONAL TEST 19';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                  Write_Result('FUNC TEST 19',model_number,serial_number);
              end;
         5180: begin
                 memo1.lines.add('ERROR:SW19');
                 Symptom.caption := 'FUNCTIONAL TEST 20';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 20',model_number,serial_number);
               end;
         5190: begin
                 memo1.lines.add('ERROR:SW20');
                 Symptom.caption := 'FUNCTIONAL TEST 21';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 21',model_number,serial_number);
               end;
         5200: begin
                 memo1.lines.add('ERROR:SW21');
                 Symptom.caption := 'FUNCTIONAL TEST 22';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 22',model_number,serial_number);
               end;
         5210: begin
                 memo1.lines.add('ERROR:SW22');
                 Symptom.caption := 'FUNCTIONAL TEST 23';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 23',model_number,serial_number);
               end;
         5220: begin
                 memo1.lines.add('ERROR:SW23');
                 Symptom.caption := 'FUNCTIONAL TEST 24';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 24',model_number,serial_number);
               end;
         5230: begin
                 memo1.lines.add('ERROR:SW24');
                 Symptom.caption := 'FUNCTIONAL TEST 25';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 25',model_number,serial_number);
               end;
         5240: begin
                 memo1.lines.add('ERROR:SW25');
                 Symptom.caption := 'FUNCTIONAL TEST 26';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 26',model_number,serial_number);
               end;
         5250: begin
                 memo1.lines.add('ERROR:SW26');
                 Symptom.caption := 'FUNCTIONAL TEST 27';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 27',model_number,serial_number);
               end;
         5260: begin
                 memo1.lines.add('ERROR : Failed STATUS request');
                 Symptom.caption := 'FUNCTIONAL TEST 28';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 28',model_number,serial_number);
               end;
         5270: begin

                 if ((status_byte and $70) = $20) then memo1.lines.add('ERROR : Device already programmed as PS4 LOCAL')
                 else if ((status_byte and $70) = $30) then memo1.lines.add('ERROR : Device already programmed as PS4 REMOTE')
                 else if ((status_byte and $70) = $40) then memo1.lines.add('ERROR : Device already programmed as PS8 LOCAL')
                 else if ((status_byte and $70) = $50) then memo1.lines.add('ERROR : Device already programmed as PS8 REMOTE')
                 else if ((status_byte and $70) = $60) then memo1.lines.add('ERROR : Device already programmed as PS16 LOCAL')
                 else if ((status_byte and $70) = $70) then memo1.lines.add('ERROR : Device already programmed as PS16 REMOTE');

                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Symptom.caption := 'FUNCTIONAL TEST 30';
                 Write_Result('FUNC TEST 30',model_number,serial_number);
                 Task_Num  := 6000;
               end;
         5280: begin
                 memo1.lines.add('ERROR : Bad LCD display');
                 Symptom.caption := 'FUNCTIONAL TEST 29';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 29',model_number,serial_number);
               end;

         6000 : begin
                 Task_Num := 6010;
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;

                 PassFail.Color   := clred;
                 PassFail.Caption := 'FAIL';

                 LCD_Line1_Str := 'FAIL FAIL FAIL FAIL';
                 LCD_Line2_Str := 'FAIL FAIL FAIL FAIL';
                 XMIT_LCD_DATA := true;
               end;

         6010: begin
                 //-- Short delay to keep message on LCD disply.
                 if Response_timer=0 then Task_Num  := LAST_TASK;

               end;

         else
           begin
             memo1.lines.add('UNDEFINED TASK NUMBER ENCOUNTERED');
             //--Symptom.Caption := 'SYSTEM GOOFED';
             Task_Num  := LAST_TASK;
             PassFail.Color := clRed;
             PassFail.Caption := 'FAIL';
           end;
       end;

end;


//-----------------------------------------------------------------------------------------
//-- Testing State Machine for robotic control
//-- Called by Timer2 every 100ms.
//-----------------------------------------------------------------------------------------
procedure TForm1.Execute_state_machine_robot;
Var
   dummy_str : string;
   txt : ansistring;

begin

       if not(Testing_enabled) then exit;

       StaticText1.Caption := IntToStr(Task_Num);

       case Task_Num of

         0 : begin  //-- Initialization
               //-- begin requesting button data from keypad.
               if robot_initialized then
                  begin
                  Task_Num := 1;
                  Keypad_Request_On := true;
                  Retries  := 0;   //-- needed for task# 6
                  end
               else if (robot_ACK) then
               begin
                  robot_initialized := True;
               end
               else
               begin
                  Form7.Show;
                  Task_Num := LAST_TASK;
               end;
             end;

         1 : begin  //-- Check Status of DUT
               Capture_State  := true;         //-- Capture button press responses
               Response_timer := 3;
               packet_found   := false;
               Task_Num       := 2;

               if model_type = 'RITEPRO' then
                 Send_RitePro_Status_Request
               else if is_it_P4 then
                 Send_P4_Status_Request
               else
                 Send_Status_Request;
             end;

         2 : begin  //-- wait for response
                if packet_found then
                  begin
                    //-- Check Version number.
                    Capture_State := false;       //-- Don't Capture button press responses

                    dummy_str := copy(Response_Str,5,2) + '.' + copy(Response_Str,7,2);

                    if Configuration.Get_Version_Number(model_number) = dummy_str then
                      begin
                        memo1.Lines.add('Firmware ver : '+dummy_str);
                        Task_Num := 3;
                      end
                    else
                      begin
                        Inc(Retries);
                        if Retries<3 then
                          begin
                            Task_Num := 1;
                          end
                        else
                          begin
                            memo1.Lines.add('Wrong Firmware Version : '+dummy_str);
                            memo1.Lines.add('Expected '+Configuration.Get_Version_Number(model_number));
                            Task_Num := 5260; 
                          end;

                      end;
                  end
                else if Response_timer=0 then
                  begin
                    Inc(Retries);
                    if Retries<3 then
                      begin
                        Task_Num := 1;
                      end
                    else
                      begin
                        //-- No response from DUT.
                        Task_Num := 4000;
                      end;
                  end;
             end;

         3 : begin
               if is_it_p4 then
                 begin
                   Task_Num := 6;
                 end
               else
                 begin
                   //-- Check to see if this device has already been programmed with it's model type.
                   status_byte := byte(Response_Str[10]);

                   //-- Check the Valid Terminal Config bit. 0 = unprogrammed.
                   status_byte2 := status_byte and $08;

                   //-- Determine what type of display has been programmed.
                   DUT_Model    := status_byte and $70;

                   //-- If this device is virgin, then continue testing.
                   if status_byte2 = 0 then Task_Num := 5

                   else
                     //-- If the device is already programmed but just being retested, continue testing.
                     //-- The DUT's 'model type' must match the barcode scan type.
                     begin
                       case DUT_Model of
                         $20 : if model_type = 'PS4LOCAL'   then Task_Num := 4 else Task_Num := 5270;
                         $30 : if model_type = 'PS4REMOTE'  then Task_Num := 4 else Task_Num := 5270;
                         $40 : if model_type = 'PS8LOCAL'   then Task_Num := 4 else Task_Num := 5270;
                         $50 : if model_type = 'PS8REMOTE'  then Task_Num := 4 else Task_Num := 5270;
                         $60 : if model_type = 'PS16LOCAL'  then Task_Num := 4 else Task_Num := 5270;
                         $70 : if model_type = 'PS16REMOTE' then Task_Num := 4 else Task_Num := 5270;
                       end;


                     end;
                 end;
             end;

         4 : begin
               case DUT_Model of
                 $20 : memo1.lines.add('Device already programmed as PS4LOCAL');
                 $30 : memo1.lines.add('Device already programmed as PS4REMOTE');
                 $40 : memo1.lines.add('Device already programmed as PS8LOCAL');
                 $50 : memo1.lines.add('Device already programmed as PS8REMOTE');
                 $60 : memo1.lines.add('Device already programmed as PS16LOCAL');
                 $70 : memo1.lines.add('Device already programmed as PS16REMOTE');
               end;

               //-- skip programming task.
               Task_Num := 6;
             end;

         //-- Program the keypad device type
         5 : begin  //-- program device type (local/remote, PS4/PS8/PS16)
               Capture_State  := false;         //-- Don't Capture button press responses
               Send_Enter_Testmode_Command;
               XDelay(100);
               Program_Device_Type;
               XDelay(4000);        //-- needed while DUT reboots

             end;

         //-- Load the button position table.
         6 : begin
               if robotposition.load_position_table(Model_Number) then
                 begin
                   Task_Num := 10;
                 end
               else
                 begin
                   Task_Num := 5400;
                 end;

             end;


         //----------------------------------------------
         //-- Button/Switch testing loop initialization
         //----------------------------------------------
         10 : begin
                if short_delay = 0 then  //-- Don't run this task until delay has expired.
                  begin
                    //-- retrieve the 1st Switch position data from position table.
                    swloopctr := 1;

                    //-- 'robotposition.get_line' is 0 based so you need to subtract 1.
                    robotposition.get_line(swloopctr-1,posXstr,posYstr,posZstr,sw_id,sw_name);
                    TASK_NUM  := 20;
                  end;
              end;

         //-- Button/Switch testing loop
         20 : begin
                 //-- If sw_id = '' then we are done and we didn't fail.
                 if sw_id = '' then
                   begin
//                     if (model_type = 'P4REMOTE') or (model_type = 'P4LOCAL') then
//                       TASK_NUM := 3100      //-- PASS for P4 testing
//                     else
//                       TASK_NUM := 40;      //-- PASS for PS testing
                      TASK_NUM := 40;
                   end

                 //-- Check to make sure this is a switch/button.
                 //-- Set up to test this next switch/button
                 else if ansicontainstext(sw_id,'SW') then
                   begin
                     memo1.lines.add('Testing '+sw_id+' ('+sw_name+')');

                     //-- Strip out just the number portion of sw_id. (sw_id looks like 'SW1','SW2',...)
                     //-- This number is needed by the 'Button_Pressed' routine.
                     txt :=  AnsiReplaceText(sw_id,'SW','');

                     switchnumber  := Tswitch_type(strtoint(txt)); //-- need to typecast to 'Tswitch_type'
memo1.lines.add('switchnumber = '+txt);

                     PASS_TASK_NUM := 30;     //-- Next Task to go to if test passes.
                     TASK_NUM      := 2000;   //-- Task Number of button test subroutine.
                   end

                 //-- This line was not a switch, grab the next item in the position table
                 else
                   begin
                     inc(swloopctr);
                     robotposition.get_line(swloopctr-1,posXstr,posYstr,posZstr,sw_id,sw_name);
                   end;
              end;

         30 : begin
                //-- This button PASSED, index to next switch/button
                inc(swloopctr);
                robotposition.get_line(swloopctr-1,posXstr,posYstr,posZstr,sw_id,sw_name);
                TASK_NUM := 20;
              end;

              //-- Home the robot before testing LCD. This helps guarantee proper
              //-- positioning of camera over LCD.
         40 : begin
                if Configuration.home_robot_before_LCD_testing then
                  begin
                    robotcomport.WriteText('home'+LF);
                    short_delay := 30;   //-- 3s
                  end;

                retries     := 3;    //-- 3 attempts to PASS
                Task_Num    := 50;
              end;

              //-- LCD Testing
         50 : begin
                if short_delay = 0 then  //-- Don't run this task until delay has expired.
                  begin
                    memo1.lines.add('Testing LCD');
                    memo1.lines.add('Retries = '+inttostr(retries));

                    //-- send LCD strings to DUT
                    Capture_State := true;
                    LCD_Line1_Str := '88888888888888888888';
                    LCD_Line2_Str := '88888888888888888888';
                    XMIT_LCD_DATA := true;
                    lcdTestOnProgress:= true;

                    //-- Move robot over LCD
                    Response_timer := 3;      //-- 3s
                    packet_found   := false;

                    robotposition.get_position('LCD',posXstr,posYstr,frameColor);

                    if posXstr <> '' then
                      begin
                        robot_moveXY(posXstr,posYstr);
                        short_delay := 20;   //-- 2s
                        Task_Num := 60;
                      end
                    else
                      begin
                        TASK_NUM := 5400;
                      end;

                  end;

              end;

         60 : begin
                if short_delay = 0 then  //-- Don't run this task until delay has expired.
                  begin
                    //select version of lcd test based on model_number

                    if  (model_number = 'GLX-LOCAL-PS-4') or
                        (model_number = 'GLX-LOCAL-PS-8') or
                        (model_number = 'GLX-LOCAL-PS-16') or
                        (model_number = 'GLX-WW-PS-16') then
                      lcdTestVersion := '0'
                    else if (model_number = 'GLX-PL-LOC-PS4') or
                            (model_number = 'GLX-PL-LOC-PS8') or
                            (model_number = 'GLX-PL-LOC-PS16') or
                            (model_number = 'GLX-LOCAL-P-4') or
                            (model_number = 'AQL-WW-P-4')then
                      lcdTestVersion := '1'
                    else if
                            (model_number = 'GLX-PL-LOC-P-4')then
                      lcdTestVersion := '2';

                    //-- Send 'testLCD command to robot
                    robotRxstr     := '';
                    robot_ACK      := false;
                    robot_NACK     := false;
                    robot_timeout  := 5;   //-- 50ms
                    Response_timer := 10;   //-- 10s
                    short_delay    := 50;   //-- 5s
                    robotcomport.WriteText('testLCD=' + LCD_Line1_Str + ',' + LCD_Line2_Str + ',' + lcdTestVersion + ',' + frameColor );
                    Task_Num := 70;
                  end;
              end;


         70 : begin
                if short_delay = 0 then  //-- Don't run this task until delay has expired.
                  begin
                    if robotRxstr <> '' then          //-- DEBUG CODE
                      begin
                        memo1.lines.add(robotRxstr);
                      end;


                    //-- Wait for response from LCD test routine
                    if robotRxstr = '11' then  //-- PASS
                      begin
                        Task_Num := 560;
                        lcdTestOnProgress:= false;
                      end

                    else
                      begin
                        if lcd_test_timeout>0 then  // Still waiting for response
                        begin
                           dec(lcd_test_timeout);
                        end
                        else //-- FAIL
                        begin
                          lcd_test_timeout:=100;
                          dec(retries);
                          if retries > 0 then
                             Task_Num := 50
                          else
                            Task_Num := 4110;
                            lcdTestOnProgress:= false;
                        end;
                      end;

                    if Response_timer = 0 then
                      begin
                        dec(retries);
                        if retries > 0 then
                           Task_Num := 50
                        else
                          Task_Num := 4120;
                          lcdTestOnProgress:= false;
                      end;

                  end;

              end;

         560: begin
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;
                 memo1.lines.add('PASS');
                 Symptom.caption := 'PASS';

                 PassFail.Color   := clLime;
                 PassFail.Caption := 'PASS';

                 LCD_Line1_Str := 'PASS PASS PASS PASS ';
                 LCD_Line2_Str := 'PASS PASS PASS PASS ';
                 XMIT_LCD_DATA := true;

                 Write_Result('PASS',model_number,serial_number);

                 robotcomport.WriteText('home'+LF);
                 short_delay := 10; //-- 1s
                 Task_Num := 3000;
              end;

         //---------------------------------------------------------------------
         //-- SUBROUTINE - Check for keypad button press.
         //---------------------------------------------------------------------
         2000: begin
                Capture_State  := true;
                Response_timer := 4;      //-- 4s
                packet_found   := false;

                if posXstr <> '' then              //-- posXstr acquired in Task 10.
                  begin
                    robot_moveXY(posXstr,posYstr);
                    short_delay := 10;   //-- 1s
                    Task_Num := 2010;
                  end
                else
                  begin
                    //--ERROR did not find model_number in position table
                    TASK_NUM := 5400;
                  end;

               end;

         2010: begin    //-- wait for ACK or NACK or timeout
                if short_delay = 0 then  //-- Don't run this task until delay has expired.
                  begin
                    if Robot_ACK then
                      begin
                        robot_moveZ(posZstr);  //-- Instruct Robot to Press SWx
                        robot_move_timeout := 30; // 30s
                        Task_Num := 2020;
                      end

                    else if Robot_NACK then
                      begin
                       // memo1.lines.add('NACK');
                        Task_Num := 5290;
                      end

                    else if robot_timeout = 0 then
                    begin
                      if robot_move_timeout>0 then  // Still waiting for response
                        begin
                           dec(robot_move_timeout);
                        end
                      else //-- FAIL
                        begin
                       // memo1.lines.add('TIMEOUT');
                          robot_move_timeout := 40;
                          Task_Num := 5300;
                        end;
                      end;

                  end;

              end;

         2020: begin    //-- wait for ACK or NACK or timeout
               if Robot_ACK then
                  begin
                    short_delay := 2;   //-- 0.2s
                    robot_release;  //-- Instruct Robot to Release SWx
                    robot_move_timeout := 30; // 3s
                    Task_Num := 2030;
                  end

                else if Robot_NACK then
                  Task_Num := 5290

                else if robot_timeout = 0 then
                    begin
                      if robot_move_timeout>0 then  // Still waiting for response
                        begin
                           dec(robot_move_timeout);
                        end
                      else //-- FAIL
                        begin
                       // memo1.lines.add('TIMEOUT');
                          robot_move_timeout := 40;
                          Task_Num := 5300;
                        end;
                      end;
               end;

         2030 : begin    //-- wait for ACK or NACK or timeout
                  if Robot_ACK then
                    begin
                      Task_Num := 2040;
                    end

                  else if Robot_NACK then
                    Task_Num := 5290

                  else if robot_timeout = 0 then
                    begin
                      if robot_move_timeout>0 then  // Still waiting for response
                        begin
                           dec(robot_move_timeout);
                        end
                      else //-- FAIL
                        begin
                       // memo1.lines.add('TIMEOUT');
                          robot_move_timeout := 40;
                          Task_Num := 5300;
                        end;
                      end;

                end;

         2040 : begin
                  //-- Wait for response from keypad
                  if packet_found then
                    begin

                      Capture_State := false;

                      if Button_Pressed(switchnumber) then
                        begin
                          //-- Correct button was pressed.  Go to next task.
                          Task_Num := PASS_TASK_NUM;
                        end
                      else
                        begin
                          //-- Wrong button was pressed
                          Task_Num := 4100;

                        end;
                    end
                  else if Response_timer=0 then
                    begin
                      //-- No response
                      if button_trial<2 then
                      begin
                        Task_Num := 2010;
                        button_trial := button_trial + 1;
                      end
                      else
                      begin
                      Task_Num := 4000;
                      button_trial := 0;
                      end;
                    end;
                end;
         //---------------------------------------------------------------------
         //-- END SUBROUTINE - Check for keypad button press.
         //---------------------------------------------------------------------


         3000: begin

                 //-- Short delay to keep message on LCD disply.
                 if Response_timer=0 then Task_Num  := LAST_TASK;

               end;
         //---------------------------------------------------------------------
         //-- These are the end of the P4 tests.
         3100 :begin
                 Task_Num := 3110;
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;
                 memo1.lines.add('PASS');
                 Symptom.caption := 'PASS';
                 PassFail.Color   := clLime;
                 PassFail.Caption := 'PASS';
                 LCD_Line1_Str := ' PASS PASS PASS ';
                 LCD_Line2_Str := ' PASS PASS PASS ';
                 XMIT_LCD_DATA := true;
                 Write_Result('PASS',model_number,serial_number);
               end;

         3110: begin
                 if Response_timer=0 then Task_Num  := LAST_TASK;
               end;
         //---------------------------------------------------------------------
               
         4000: begin
                 memo1.lines.add('No Response from Control Pad.  Fail '+sw_id);
                 Symptom.caption  := 'FUNC TEST 1';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 1',model_number,serial_number);
                 robotcomport.WriteText('home'+LF);
               end;

         4100: begin
                 memo1.lines.add('Wrong button repsonse. Fail '+sw_id);
                 Symptom.caption  := 'FUNC TEST 1';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 1',model_number,serial_number);
                 robotcomport.WriteText('home'+LF);
               end;

         4110: begin
                 memo1.lines.add('LCD Fail');
                 Symptom.caption  := 'LCD Fail';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('LCD Fail',model_number,serial_number);
                 robotcomport.WriteText('home'+LF);
               end;

         4120: begin
                 memo1.lines.add('LCD response Fail');
                 Symptom.caption  := 'LCD Fail';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('LCD response Fail',model_number,serial_number);
                 robotcomport.WriteText('home'+LF);
               end;

         5000: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW7');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW1');
                  end;
                 Symptom.caption  := 'FUNC TEST 2';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num         := 6000;
                 Write_Result('FUNC TEST 2',model_number,serial_number);
               end;
         5010: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW8');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW2');                  
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 3';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 3',model_number,serial_number);
               end;
         5020: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW9');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW3');                  
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 4';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 4',model_number,serial_number);
               end;
         5030: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW11');
                  end
                 else 
                  begin 
                    memo1.lines.add('ERROR:SW4');                  
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 5';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 5',model_number,serial_number);
               end;
         5040: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW10');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW5');                  
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 6';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 6',model_number,serial_number);
               end;
         5050: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW6');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW6');                  
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 7';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 7',model_number,serial_number);
               end;
         5060: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW5');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW7');
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 8';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 8',model_number,serial_number);
               end;
         5070: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW3');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW8');
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 9';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 9',model_number,serial_number);
               end;
         5080: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW2');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW9');
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 10';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 10',model_number,serial_number);
               end;
         5090: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW1');
                  end
                 else
                  begin 
                    memo1.lines.add('ERROR:SW10');
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 11';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 11',model_number,serial_number);
               end;
         5100: begin
                 if is_it_p4 then
                  begin
                    memo1.Lines.Add('ERROR:SW4');
                  end
                 else
                  begin
                    memo1.lines.add('ERROR:SW11');
                  end;
                 Symptom.caption := 'FUNCTIONAL TEST 12';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 12',model_number,serial_number);
               end;
         5110: begin
                 memo1.lines.add('ERROR:SW12');
                 Symptom.caption := 'FUNCTIONAL TEST 13';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 13',model_number,serial_number);
               end;
         5120: begin
                 memo1.lines.add('ERROR:SW13');
                 Symptom.caption := 'FUNCTIONAL TEST 14';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 14',model_number,serial_number);
               end;
         5130: begin
                 memo1.lines.add('ERROR:SW14');
                 Symptom.caption := 'FUNCTIONAL TEST 15';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 15',model_number,serial_number);
               end;
         5140: begin
                 memo1.lines.add('ERROR:SW15');
                 Symptom.caption := 'FUNCTIONAL TEST 16';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 16',model_number,serial_number);
               end;
         5150: begin
                 memo1.lines.add('ERROR:SW16');
                 Symptom.caption := 'FUNCTIONAL TEST 17';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 17',model_number,serial_number);
               end;
         5160: begin
                 memo1.lines.add('ERROR:SW17');
                 Symptom.caption := 'FUNCTIONAL TEST 18';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 18',model_number,serial_number);
               end;
         5170: begin
                 memo1.lines.add('ERROR:SW18');
                 Symptom.caption := 'FUNCTIONAL TEST 19';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                  Write_Result('FUNC TEST 19',model_number,serial_number);
              end;
         5180: begin
                 memo1.lines.add('ERROR:SW19');
                 Symptom.caption := 'FUNCTIONAL TEST 20';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 20',model_number,serial_number);
               end;
         5190: begin
                 memo1.lines.add('ERROR:SW20');
                 Symptom.caption := 'FUNCTIONAL TEST 21';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 21',model_number,serial_number);
               end;
         5200: begin
                 memo1.lines.add('ERROR:SW21');
                 Symptom.caption := 'FUNCTIONAL TEST 22';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 22',model_number,serial_number);
               end;
         5210: begin
                 memo1.lines.add('ERROR:SW22');
                 Symptom.caption := 'FUNCTIONAL TEST 23';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 23',model_number,serial_number);
               end;
         5220: begin
                 memo1.lines.add('ERROR:SW23');
                 Symptom.caption := 'FUNCTIONAL TEST 24';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 24',model_number,serial_number);
               end;
         5230: begin
                 memo1.lines.add('ERROR:SW24');
                 Symptom.caption := 'FUNCTIONAL TEST 25';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 25',model_number,serial_number);
               end;
         5240: begin
                 memo1.lines.add('ERROR:SW25');
                 Symptom.caption := 'FUNCTIONAL TEST 26';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 26',model_number,serial_number);
               end;
         5250: begin
                 memo1.lines.add('ERROR:SW26');
                 Symptom.caption := 'FUNCTIONAL TEST 27';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 27',model_number,serial_number);
               end;
         5260: begin
                 memo1.lines.add('ERROR : Failed STATUS request');
                 Symptom.caption := 'FUNCTIONAL TEST 28';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 28',model_number,serial_number);
               end;
         5270: begin

                 if ((status_byte and $70) = $20) then memo1.lines.add('ERROR : Device already programmed as PS4 LOCAL')
                 else if ((status_byte and $70) = $30) then memo1.lines.add('ERROR : Device already programmed as PS4 REMOTE')
                 else if ((status_byte and $70) = $40) then memo1.lines.add('ERROR : Device already programmed as PS8 LOCAL')
                 else if ((status_byte and $70) = $50) then memo1.lines.add('ERROR : Device already programmed as PS8 REMOTE')
                 else if ((status_byte and $70) = $60) then memo1.lines.add('ERROR : Device already programmed as PS16 LOCAL')
                 else if ((status_byte and $70) = $70) then memo1.lines.add('ERROR : Device already programmed as PS16 REMOTE');

                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Symptom.caption := 'FUNCTIONAL TEST 30';
                 Write_Result('FUNC TEST 30',model_number,serial_number);
                 Task_Num  := 6000;
               end;
         5280: begin
                 memo1.lines.add('ERROR : Bad LCD display');
                 Symptom.caption := 'FUNCTIONAL TEST 29';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('FUNC TEST 29',model_number,serial_number);
               end;

         5290: begin
                 memo1.lines.add('ERROR : NO ROBOT RESPONSE');
                 Symptom.caption := 'ROBOT FAILURE';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('ROBOT FAILURE',model_number,serial_number);
               end;

         5300: begin
                 memo1.lines.add('ERROR : ROBOT-TIMEOUT');
                 Symptom.caption := 'ROBOT FAILURE';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('ROBOT FAILURE',model_number,serial_number);
               end;
         5400: begin
                 memo1.lines.add('ERROR : MISSING POSITION DATA');
                 Symptom.caption := 'MISSING POSITION DATA';
                 PassFail.Color   := clRed;
                 PassFail.Caption := 'FAIL';
                 Task_Num  := 6000;
                 Write_Result('MISSING POSITION DATA',model_number,serial_number);
               end;

         6000 : begin
                 Task_Num := 6010;
                 Response_timer := 3;
                 Capture_State  := true;
                 packet_found   := false;

                 PassFail.Color   := clred;
                 PassFail.Caption := 'FAIL';

                 LCD_Line1_Str := 'FAIL FAIL FAIL FAIL';
                 LCD_Line2_Str := 'FAIL FAIL FAIL FAIL';
                 XMIT_LCD_DATA := true;
               end;

         6010: begin
                 //-- Short delay to keep message on LCD disply.
                 if Response_timer=0 then Task_Num  := LAST_TASK;

               end;

         LAST_TASK :
               begin
                 Start.enabled     := true;
                 Keypad_Request_On := false;
                 Capture_State     := false;
                 Start.SetFocus;
                 Testing_enabled := false;
//                 Task_Num := 0;
//                 if memo1.lines.Text.Contains('PASS') then
//                 begin
//                    counter_pass := counter_pass+1;
//                 end
//                 else
//                  begin
//                  counter_fail := counter_fail+1;
//                  end;
//                 memo1.Lines.Add('PASS: ' + counter_pass.ToString);
//                 memo1.Lines.Add('FAIL: ' + counter_fail.ToString);
//                 XDelay(1000);
//                 memo1.Clear;
//                 AssignFile(myFile,'test.txt');
//                 ReWrite(myFile);
//                 WriteLn(myFile,'PASS: ' + counter_pass.ToString);
//                 WriteLn(myFile,'FAIL: ' + counter_fail.ToString);
//                 CloseFile(myFile);
               end;
         else
           begin
             memo1.lines.add('UNDEFINED TASK NUMBER ENCOUNTERED');
             //--Symptom.Caption := 'SYSTEM GOOFED';
             Task_Num  := LAST_TASK;
             PassFail.Color := clRed;
             PassFail.Caption := 'FAIL';
           end;
       end;


end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Init_Everything;
var
  Str: String;
begin
     initialization_ok := true;

     Ver_Label.caption    := 'Version:'+VERSION;
     Start.Enabled        := true;
     Comports_Configured  := false;
     comport1_configured  := false;
     COM_Ports_OK         := false;
     Comm_Error_Tmr       := 5;
     slider_thing         := 0;
     previous_model_type  := '';


     DisplayComport.DeviceName     := Configuration.Get_Display_Comport;
     DisplayProgComport.DeviceName := Configuration.Get_Display_Programming_Comport;
     genIbasecomport.DeviceName    := Configuration.Get_GenI_Base_Comport;
     genIIbasecomport.DeviceName   := Configuration.Get_GenII_Base_Comport;
     RobotComport.DeviceName       := Configuration.Get_Robot_Comport;

     if Configuration.Display_Comport_Enabled then
       try
         DisplayComport.Open;
       Except
         if not(DisplayComport.Active) then
           begin
             memo1.lines.add('Unable to open ''Display Comport'' '+DisplayComport.DeviceName);
             initialization_ok := false;
           end;
       end;

     if Configuration.Display_Prog_Comport_Enabled then
       try
         DisplayProgComport.Open;
       Except
         if not(DisplayProgComport.Active) then
           begin
             memo1.lines.add('Unable to open ''Display Programming Comport'' '+DisplayProgComport.DeviceName);
             initialization_ok := false;
           end;
       end;

     if Configuration.GenI_Base_Comport_Enabled then
       try
         genIbasecomport.Open;
       Except
         if not(genIbasecomport.Active) then
           begin
             memo1.lines.add('Unable to open ''Gen I Base Radio Comport'' '+genIbasecomport.DeviceName);
             initialization_ok := false;
           end;
       end;

     if Configuration.GenII_Base_Comport_Enabled then
       try
         genIIbasecomport.Open;
       Except
         if not(genIIbasecomport.Active) then
           begin
             memo1.lines.add('Unable to open ''Gen II Base Radio Comport'' '+genIIbasecomport.DeviceName);
             initialization_ok := false;
           end;
       end;

     if Configuration.Robot_Comport_Enabled then
       try
         RobotComport.Open;
         RobotComport.WriteText('startPi'+LF);
//         XDelay(5000);
         RobotComport.WriteText('home'+LF);
//         XDelay(1000);
//         if not (trim(robotcomport.ReadText) = 'ACK') then
//           begin
//             Form7.Show;
//             initialization_ok := false;
//           end;

       Except
         if not(RobotComport.Active) then
           begin
             memo1.lines.add('Unable to open ''Robot Comport'' '+RobotComport.DeviceName);
             initialization_ok := false;
           end;
       end;


     //-- Open RS485 channel.
     DisplayComDataPacket1.DataStart    := #$10#$02;
     DisplayComDataPacket1.DataFinish     := #$10#$03;
//     ComDataPacket1.IncludeStrings := false;


     Req_Button_Data_Received := false;
     LED_Data_Received        := false;
     LCD_Data_Received        := false;
     pos_edge_already_sent    := false;
     
     test_mode     := False;
     DLE_Found     := False;
     STX_Found     := False;
     ETX_Found     := False;
     Previous_byte := 0;
     Output_Type   := 0;       //-- HEX

     LCD_Line1_Str := '';
     LCD_Line2_Str := '';

     Task_Num      := 0;
     Timeout1_Ctr  := 0;

     CMD_Found    := false;
     CMD_Received := false;
     Str3         := '';
     RC_CTR       := 0;
     RC_CMD       := 0;
     Byte_Ctr     := 0;

     Status.Visible  := false;


     //---------------------------------------------------------------
     //---------------------------------------------------------------
     if initialization_ok then
       memo1.lines.add('Press START to begin')
     else
       begin
         memo1.lines.add('ERROR during initialization. Testing disabled.');
         Start.Enabled := false;
       end;

end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
begin
     homedir := getcurrentdir;

     Keypad_Request_On   := false;     //-- turns 100ms keypad request on and off.
     XMIT_LCD_Data       := false;     //-- toggles between transmission of LCD data and button requests.
     XMIT_LED_Data       := false;     //-- toggles between transmission of LED data and button requests.

     Testing_enabled     := false;
end;


{
//------------------------------------------------------------------------------
//-- COMPORT1 is monitoring the RS485 bus.
//------------------------------------------------------------------------------
procedure TForm1.ComPort1RxChar(Sender: TObject; Count: Integer);
Var
   i : word;
   Str1,Str : String;
begin
  //-- See how many bytes are in the RS232 receive buffer.
  Str           := '';
  Str1          := '';
  packet_found  := false;

  Count := Comport1.inputcount;
  ComPort1.ReadText(Str, Count);

  for i := 1 to Count do
    begin
      if Capture_State then
        begin
          Str1 := Str1 + Str[i];

          Str2 := Str2 + Str[i];

          if (byte(Str[i]) = $03) and (Previous_byte = $10) then
            begin
              packet_found := true;
              Response_Str := Str2;

              Str2 := '';
            end;

          Previous_byte := byte(Str[i]);

        end;    //--if Capture_State then
    end;    //-- for i loop

end;
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.Timer1Timer(Sender: TObject);
begin
     //-- This timer is set for 1000ms intervals.

     If Response_timer > 0 then dec(Response_timer);

end;

//------------------------------------------------------------------------------
//-- 100ms keypad request timer.
//------------------------------------------------------------------------------
procedure TForm1.Timer2Timer(Sender: TObject);
begin
     timer2.enabled := false;

     if robot_timeout > 0 then dec(robot_timeout);

     if short_delay > 0 then dec(short_delay);

     if Keypad_Request_On then
       begin

         if XMIT_LCD_Data then
           begin
             Send_LCD_Data(LCD_Line1_Str,LCD_Line2_Str);
             if lcdTestOnProgress = false then
                XMIT_LCD_Data := false;
           end
        else  if XMIT_LED_Data then
           begin
             Send_LED_Data(LED1,LED2,LED3,LED4);
             XMIT_LED_Data := false;
           end
         else Send_Button_Request_Command;

         inc(slider_thing);
         if slider_thing >=10 then slider_thing := 0;

         case slider_thing of
           0 : label1.Caption := '-         ';
           1 : label1.Caption := ' -        ';
           2 : label1.Caption := '  -       ';
           3 : label1.Caption := '   -      ';
           4 : label1.Caption := '    -     ';
           5 : label1.Caption := '     -    ';
           6 : label1.Caption := '      -   ';
           7 : label1.Caption := '       -  ';
           8 : label1.Caption := '        - ';
           9 : label1.Caption := '         -';
         end;

       end;

     if Testing_enabled then
       if Configuration.Get_Testing_type(Model_Number)='ROBOT' then
         Execute_state_machine_robot
       else
         Execute_state_machine_manual;

     timer2.enabled := true;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.StopClick(Sender: TObject);
begin
     //-- Kill testing
     CMD_Received := true;
     Task_Num     := LAST_TASK;
     memo1.lines.add('TESTING STOPPED.');
     Symptom.Caption  := '';
     PassFail.Color   := clRed;
     PassFail.Caption := 'FAIL';
end;



//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.FormShow(Sender: TObject);
Var
   username_result : integer;
   Done : boolean;
begin
     if Configuration.Init_Configuration then
       begin
         //--memo1.lines.add('Configure ok.');
       end
     else
       begin
         memo1.lines.add('Configure fail.');
         memo1.lines.add('Unable to load Valid_models.dat');
       end;

     Init_Everything;


     //-- Validate Username and Password.
//     usenamepassword.Load_Username_Table;
//
//     Done := false;
//     Repeat
//       username_result := usenamepassword.showmodal;
//       done := true;
//       break;
//
//       if username_result = mrCancel then
//         begin
//           Application.terminate;
//           Done := true;
//         end
//       else if Not(usenamepassword.Valid) then Showmessage('Invalid Username or Password')
//       else
//         begin
//           Done := true;
//         //  usenamepassword.update_username_list;
//         end;
//
//     Until Done;

     if usenamepassword.Get_Username = '' then
       label3.Caption := 'Logged in as ghost'
     else
       label3.Caption := 'Logged in as '+usenamepassword.Get_Username;
end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.FormActivate(Sender: TObject);
begin

end;

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.StatusClick(Sender: TObject);
begin

end;


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
procedure TForm1.Comport1RS4821Click(Sender: TObject);
begin
//     Comport1.ShowSetupDialog;
end;




procedure TForm1.Database1Click(Sender: TObject);
begin
  dbinterface.showmodal;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Write_Result(symptom,model_number,serial_number:string);
Var
   temp_str : string;
begin

     //-- Write pass/fail code to SQL dB.
     if configuration.Qdb_Enabled then
      begin
         dbinterface.Save_Test_Result(serial_number,model_number,PROCESS_STEP,FIXTURE,symptom);
      end;

     //-- Save a copy of the results to a local file.
     if (uppercase(copy(model_number,1,3))='AQL') or
        (uppercase(copy(model_number,1,3))='GLX') then
       temp_str := serial_number + ',' +
                   symptom       + ',' +
                   PROCESS_STEP  + ',' +
                   FIXTURE       + ',' +
                   model_number  + ',' +
                   DateTimeToStr(Now)
     else
       temp_str := model_number +' '+serial_number + ',' +
                   symptom       + ',' +
                   PROCESS_STEP  + ',' +
                   FIXTURE       + ',' +
                   model_number  + ',' +
                   DateTimeToStr(Now);

     If FIleExists(LOCAL_OUTPUT_FILENAME) then
       begin
         //-- Write data to local test results output file.
         AssignFile(Local_Test_Results_File,LOCAL_OUTPUT_FILENAME);
         Append(Local_Test_Results_File);
       end
     else
       begin
         AssignFile(Local_Test_Results_File,LOCAL_OUTPUT_FILENAME);
         Rewrite(Local_Test_Results_File);
       end;

     Writeln(Local_Test_Results_File,temp_str);
     closefile(Local_Test_Results_File);



     //-------------------------------------------------
     //-- Write data to output file for Quality DB.
     //-------------------------------------------------
     if Configuration.Qdb_Enabled then
       begin
         AssignFile(Test_Results_File,OUTPUT_FILENAME);

         {$I-} Reset(Test_Results_File);  {$I+}
         If IOResult = 0 then
           begin
             //-- At this point the file exists so we need to open it for Appending.
             Append(Test_Results_File);
           end
         else
           begin
             //-- Attempt to create the file.
             {$I-} Rewrite(Test_Results_File);  {$I+}
             If IOResult <> 0 then
               begin
                  showmessage('Error creating '+OUTPUT_FILENAME+' file.  Call Engineer!');
                  exit;
               end;

           end;

         if (uppercase(copy(model_number,1,3))='AQL') or
            (uppercase(copy(model_number,1,3))='GLX') then
           temp_str := serial_number + DELIMITER +
                       symptom       + DELIMITER +
                       PROCESS_STEP  + DELIMITER +
                       FIXTURE       + DELIMITER +
                       model_number
         else
           temp_str := model_number +' '+serial_number + DELIMITER +
                       symptom       + DELIMITER +
                       PROCESS_STEP  + DELIMITER +
                       FIXTURE       + DELIMITER +
                       model_number;

         Writeln(Test_Results_File,temp_str);

         closefile(Test_Results_File);

         //-- Call QDB application.
//--         Winexec(APPLICATION_FILENAME, 1)    //-- 1 = application is visible, 0 = in background.
       end
     else
       memo1.lines.add('Qdb not enabled.');
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Configuration1Click(Sender: TObject);
begin
     //--
     Configuration.showmodal;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Positiontable1Click(Sender: TObject);
begin
    robotposition.Show;
end;

//------------------------------------------------------------------------------
//--   PS4LOCAL     = PS4 local
//--   PS4REMOTE    = PS4 remote
//--   PS4REMOTERF  = PS4 RF
//--
//--   PS8LOCAL     = PS8 local
//--   PS8REMOTE    = PS8 remote
//--   PS8REMOTERF  = PS8 RF
//--
//--   PS16LOCAL    = PS16 local
//--   PS16REMOTE   = PS16 remote
//--   PS16REMOTERF = PS16 RF
//--
//--   PS32LOCAL    = PS32 local
//--   PS32REMOTE   = PS32 remote
//--   PS32REMOTERF = PS32 RF
//------------------------------------------------------------------------------
procedure TForm1.Program_Device_Type;
Var
   d_data,Check_sum : byte;
   cmd_str : ansistring;
begin
         //-- Send Button request command to display.
         cmd_str :=#$10#$02#$01#$87;
         Check_sum := $10 + $02 + $01 + $87;

         d_data := $01 ; //-- Set as default,  1=PS4, 2=PS8, 3=PS16
         if ((model_type = 'PS4LOCAL') or
             (model_type = 'PS4REMOTE') or
             (model_type = 'PS4REMOTERF')) then d_data := $01

         else if ((model_type = 'PS8LOCAL') or
                  (model_type = 'PS8REMOTE') or
                  (model_type = 'PS8REMOTERF')) then d_data := $02

         else if ((model_type = 'PS16LOCAL') or
                  (model_type = 'PS16REMOTE') or
                  (model_type = 'PS16REMOTERF')) then d_data := $03;

         cmd_str := cmd_str + ansichar(d_data);
         Check_sum := Check_sum + d_data;

         d_data := $02;   //-- Set as default, 2=local, 3=remote
         if ((model_type = 'PS4LOCAL') or (model_type = 'PS8LOCAL') or
             (model_type = 'PS16LOCAL') or (model_type = 'PS32LOCAL')) then d_data := $02
         else if ((model_type = 'PS4REMOTE')  or (model_type = 'PS4REMOTERF') or
                  (model_type = 'PS8REMOTE')  or (model_type = 'PS8REMOTERF') or
                  (model_type = 'PS16REMOTE') or (model_type = 'PS16REMOTERF') or
                  (model_type = 'PS32REMOTE') or (model_type = 'PS32REMOTERF')) then d_data := $03;

         cmd_str := cmd_str + ansichar(d_data);
         Check_sum := Check_sum + d_data;

         cmd_str := cmd_str + #$00;               //-- Check sum hi
         cmd_str := cmd_str + ansichar(Check_sum);    //-- Check sum hi

         cmd_str := cmd_str + #$10#$03;

         Displaycomport.WriteText(cmd_str);

         Last_Command_Issued := $87;

end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.robotbtnClick(Sender: TObject);
begin
    robotcomport.WriteText('break'+LF);
end;

procedure TForm1.robotcomportRxChar(Sender: TObject; Count: Integer);
begin
    if not(robotcommbusy) then
      begin
        robotcommbusy := true;

        robotRxstr := trim(robotcomport.ReadText);

        if robotRxstr = 'ACK' then
          begin
            robot_ACK := true;
          end
        else if robotRxstr = 'NACK' then
          begin
            robot_NACK := true;
          end;

        robotcommbusy := false;
      end;
end;

procedure TForm1.robotOFF1Click(Sender: TObject);
begin
    robotcomport.WriteText('break'+LF);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.robot_moveXY(Xstr,Ystr: ansistring);
var
    cmdstr : ansistring;
begin

    //-- Build command string
    cmdstr := 'moveXY=' + Xstr + ',' + Ystr + LF;

    robot_ACK  := false;
    robot_NACK := false;
    robot_timeout := 5;   //-- 500ms

    //-- transmit command
    robotcomport.WriteText(cmdstr);
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.robot_moveZ(Zstr: ansistring);
var
    cmdstr : ansistring;
begin
    //-- Build command string
    cmdstr := 'moveZ='+Zstr+LF;

    robot_ACK  := false;
    robot_NACK := false;
    robot_timeout := 5;   //-- 500ms

    //-- transmit command
    robotcomport.WriteText(cmdstr);
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.robot_release;
begin
    robot_ACK  := false;
    robot_NACK := false;
    robot_timeout := 5;   //-- 5ms

    //-- transmit command
    robotcomport.WriteText('release'+LF);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_Enter_Testmode_Command;
Var
   cmd_str : ansistring;
begin
         //-- Send Button request command to display.
         cmd_str :=#$10#$02#$01#$80#$00#$93#$10#$03;
         Displaycomport.WriteText(cmd_str);
         Last_Command_Issued := $80;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_Status_Request;
Var
   cmd_str : ansistring;
begin
         //-- Send Button request command to display.
         cmd_str :=#$10#$02#$01#$8B#$00#$9E#$10#$03;
         Displaycomport.WriteText(cmd_str);
         Last_Command_Issued := $8B;

end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_P4_Status_Request;
Var
   d_data : byte;
   cmd_str : ansistring;
begin
     cmd_str :=#$10#$02#$01#$8A#$00#$9D#$10#$03;
     Displaycomport.WriteText(cmd_str);
     Last_Command_Issued := $8B;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Settings1Click(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_RitePro_Status_Request;
Var
   cmd_str : ansistring;
begin
     //-- Send Button request command to display.
     cmd_str :=#$10#$02#$01#$8A#$00#$9D#$10#$03;
     Displaycomport.WriteText(cmd_str);
     Last_Command_Issued := $8B;

end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_Button_Request_Command;
Var
   cmd_str : ansistring;
begin
     //-- Send Button request command to display.
     cmd_str :=#$10#$02#$01#$01#$00#$14#$10#$03;
     Displaycomport.WriteText(cmd_str);
     Last_Command_Issued := $01;

     inc(BR_XMIT);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_LCD_Data(line1_str,Line2_str:string);
Var
   i,d_data,ch_cnt : byte;
   CRC      : word;
   cmd_str : ansistring;
begin
//--memo1.lines.add('Sending LCD data.');

         //-- Send Button request command to display.
         cmd_str := #$10#$02#$01#$03;
         CRC := $16;

         ch_cnt := 20;     //-- number of LCD characters/line

         //-- Send LCD line 1 data
         for i := 1 to ch_cnt do
           begin
             if i <= length(line1_str) then
               d_data := byte(line1_str[i])
             else
               d_data := byte(' ');

             CRC := CRC + d_data;
             cmd_str := cmd_str + ansichar(d_data);

             //-- Check for a 0x10.  Stuff a null if it is.
             if d_data = $10 then
               begin
                 d_data := $00;
                 cmd_str := cmd_str + ansichar(d_data);
               end;
           end;

         //-- Send LCD line 2 data
         for i := 1 to ch_cnt do
           begin
             if i <= length(line2_str) then
               d_data := byte(line2_str[i])
             else
               d_data := byte(' ');

             CRC := CRC + d_data;
             cmd_str := cmd_str + ansichar(d_data);

             //-- Check for a 0x10.  Stuff a null if it is.
             if d_data = $10 then
               begin
                 d_data := $00;
                 cmd_str := cmd_str + ansichar(d_data);
               end;
           end;

         d_data := $00;
         cmd_str := cmd_str + ansichar(d_data);       //-- Display flags
         CRC    := CRC + d_data;

         d_data := byte(CRC div 256);
         cmd_str := cmd_str + ansichar(d_data);       //-- CRC hi

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         d_data := byte(CRC and $00FF);
         cmd_str := cmd_str + ansichar(d_data);       //-- CRC lo

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         cmd_str := cmd_str + #$10#$03;
         Displaycomport.WriteText(cmd_str);
         Last_Command_Issued := $03;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TForm1.Send_LED_Data(L1,L2,L3,L4:byte);
Var
   d_data : byte;
   CRC    : word;
   cmd_str : ansistring;
begin
//--memo1.lines.add('Sending LED data.');

         //-- Send Button request command to display.
         cmd_str := #$10#$02#$01#$02;
         CRC := $15;

         //----------------------
         //-- Send LED1 data
         //----------------------
         d_data := L1;
         CRC := CRC + d_data;
         cmd_str := cmd_str + ansichar(d_data);

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- Send LED2 data
         //----------------------
         d_data := L2;
         CRC := CRC + d_data;
         cmd_str := cmd_str + ansichar(d_data);

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
            cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- Send LED3 data
         //----------------------
         d_data := L3;
         CRC := CRC + d_data;
         cmd_str := cmd_str + ansichar(d_data);

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- Send LED4 data
         //----------------------
         d_data := L4;
         CRC := CRC + d_data;
         cmd_str := cmd_str + ansichar(d_data);

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- Send blink data data
         //----------------------
         cmd_str := cmd_str + #$00#$00#$00#$00;

         //----------------------
         //-- CRC hi data
         //----------------------
         d_data := byte(CRC div 256);
         cmd_str := cmd_str + ansichar(d_data);       //-- CRC hi

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- CRC lo data
         //----------------------
         d_data := byte(CRC and $00FF);
         cmd_str := cmd_str + ansichar(d_data);       //-- CRC lo

         //-- Check for a 0x10.  Stuff a null if it is.
         if d_data = $10 then
           begin
             d_data := $00;
             cmd_str := cmd_str + ansichar(d_data);
           end;

         //----------------------
         //-- trailer data
         //----------------------
         cmd_str := cmd_str + #$10#$03;
         Displaycomport.WriteText(cmd_str);

         Last_Command_Issued := $02;
end;


//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
procedure TForm1.ComDataPacket1Discard(Sender: TObject; const Str: String);
begin
     memo1.lines.add('packet discarded.');
end;

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
procedure TForm1.DisplayComDataPacket1Message(Sender: TObject; const Data: AnsiString);
Var
   i,j : word;
   temp_str : String;
begin
      packet_found := false;
//  memo1.Lines.Add(Data);

      if Capture_state then
        begin

          DecodeMessage(Data);


          Temp_Str := '';

          //-- Scan str and remove all embedded nulls. Copy to a temporary buffer.
          j := 1;   //-- Start of Str

          Repeat
            begin
              Temp_str := Temp_Str + Data[j];
              if (byte(Data[j]) = $10) then
                begin
                  if  (byte(Data[j+1]) = 0) then inc(j,2)
                  else inc(j);
                end
              else
                begin
                  inc(j);
                end;
            end;
          Until j > length(Data);

          //-- Copy payload to RC_BUFFER.
          for i := 1 to Length(Temp_Str) do RC_Buffer[i] := byte(Temp_Str[i]);

          Response_Str := #10 + #02 + Temp_Str + #10 + #03;
          packet_found := true;



//--memo1.lines.add('packet received.');
        end;
end;



//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
procedure TForm1.DecodeMessage(MesData : ansistring);
var
  i,j : word;
  temp_str : AnsiString;
begin

  //     temp_str := MesData;
       //  packet_found := false;
// memo1.Lines.Add(mesdata);


         Temp_Str := '';

          //-- Scan str and remove all embedded nulls. Copy to a temporary buffer.
          j := 1;   //-- Start of Data
          Repeat
            begin
              Temp_str := Temp_Str + ansichar(MesData[j]);
              if (byte(MesData[j]) = $10) then
                begin
                  if  (byte(MesData[j+1]) = 0) then inc(j,2)
                  else inc(j);
                end
              else
                begin
                  inc(j);
                end;

            end;
          Until j > length(MesData);


          //-- Copy payload to RC1_BUFFER.
          for i := 1 to Length(temp_str) do RC_Buffer[i] := byte(Temp_Str[i]);

          Response_Str := #$10 + #$02 + temp_str + #$03;      // the $10 in ending message is always left in
          packet_found := true;
end;

end.
