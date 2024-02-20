function varargout = pro_man(varargin)
% PRO_MAN M-file for pro_man.fig
%      PRO_MAN, by itself, creates a new PRO_MAN or raises the existing
%      singleton*.
%
%      H = PRO_MAN returns the handle to a new PRO_MAN or the handle to
%      the existing singleton*.
%
%      PRO_MAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRO_MAN.M with the given input arguments.
%
%      PRO_MAN('Property','Value',...) creates a new PRO_MAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pro_man_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pro_man_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pro_man

% Last Modified by GUIDE v2.5 09-Nov-2009 17:18:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pro_man_OpeningFcn, ...
                   'gui_OutputFcn',  @pro_man_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pro_man is made visible.
function pro_man_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pro_man (see VARARGIN)

% Choose default command line output for pro_man
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pro_man wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pro_man_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function mycallback(hObject, eventdata, handles)
    file = uigetfile('*.m');
    fid = fopen('current.model','a');
    fprintf(fid,'%s\n',file);

          %This function should be added to your path
      % ---------------------------------------------
      function nodes = myExpfcn(tree, value)

      try
          count = 0;
          ch = dir(value);

          for i=1:length(ch)
              if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
                  count = count + 1;
                  if ch(i).isdir
                      iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
                  else
                      iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
                  end
                  nodes(count) = uitreenode([value, ch(i).name, filesep], ...
                      ch(i).name, iconpath, ~ch(i).isdir);
              end
          end
      catch
          error('MyApplication:UnrecognizedNode', ...
            ['The uitree node type is not recognized. You may need to ', ...
            'define an ExpandFcn for the nodes.']);
      end

      if (count == 0)
          nodes = [];
    	end
      % ---------------------------------------------

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=figure;
a=get(h,'position');
lenght = a(3);
width = a(4);

root1=uitreenode('v0','New','New Receiver',[],false);
t1 = uitree('v0', h, 'Root', root1, 'Position',[0 0 (lenght-100)/2 width]);

root2 = uitreenode('v0', 'Root', 'D:\',[],false);
t2 = uitree('v0',h, 'Root', root2, 'Position',[(lenght+100)/2 0 (lenght-100)/2 width],...
    'ExpandFcn', @myExpfcn, 'SelectionChangeFcn', 'disp(''Selection Changed'')');


addbutton = uicontrol('style','pushbutton','string','Add',...
    'position', [(lenght-40)/2 220 60 20],'Callback', @mycallback);


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load(uigetfile('*.model'));
t = uitree('v0', f, 'Root', root, 'Position',[0 0 300 400]);


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
root = uitreenode('v0', 'receiver', 'No Open Project', [], false);
t = uitree('v0', hObject, 'Root', root, 'Position',[0 0 300 400]);

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
