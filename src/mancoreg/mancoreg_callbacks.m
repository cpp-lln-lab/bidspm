function mancoreg_callbacks(op,varargin);            
%
% Callback routines for mancoreg.m 
%
% Change LOG
% 
% Version 1.0.1    
% Radio button cannot be turned off on matlab for linux (6.5.0). Changed to
% two radio buttons for toggle on/off (12.1.2004, JH)
%
% Version 1.0.2    
% Added:    Plot of transformation matrix, values are shown next to sliders
%           and "reset transformation" button (12.1.2004, JH)
%

	global st mancoregvar;
	
 
% 'move'
% Update the position of the bottom (source) image according to user settings
%----------------------------------------------------------------------------

    if strcmp(op,'move'),       
        
        angl_pitch=get(mancoregvar.hpitch,'Value');
        angl_roll=get(mancoregvar.hroll,'Value');
        angl_yaw=get(mancoregvar.hyaw,'Value');
	
        dist_x=get(mancoregvar.hx,'Value');
        dist_y=get(mancoregvar.hy,'Value');
        dist_z=get(mancoregvar.hz,'Value');
        
        set(mancoregvar.hpitch_val,'string',num2str(angl_pitch));
        set(mancoregvar.hroll_val,'string',num2str(angl_roll));
        set(mancoregvar.hyaw_val,'string',num2str(angl_yaw));
	
        set(mancoregvar.hx_val,'string',num2str(dist_x));
        set(mancoregvar.hy_val,'string',num2str(dist_y));
        set(mancoregvar.hz_val,'string',num2str(dist_z));

        mancoregvar.sourceimage.premul=spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);
        if (get(mancoregvar.htoggle_on,'value')==0) % source is currently displayed
        st.vols{2}.premul=spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);    
        end
        
        plotmat;
        spm_orthviews('redraw');
        
        return
	end
	

% 'toggle_off'
% Toggles between source and target display in bottom window
%--------------------------------------------------------------------------

if strcmp(op,'toggle_off'), 
       
        if (get(mancoregvar.htoggle_off,'value')==0)    % Source is to be displayed
        
            set(mancoregvar.htoggle_off,'value',1);
            
        else
                
            set(mancoregvar.htoggle_on,'value',0);
            st.vols{2}=mancoregvar.sourceimage;
            spm_orthviews('redraw');
            
                        
        end
        
        return
	end
	
	
% 'toggle_on'
% Toggles between source and target display in bottom window
%--------------------------------------------------------------------------

if strcmp(op,'toggle_on'), 
       
        if (get(mancoregvar.htoggle_on,'value')==0)    % Source is to be displayed
        
            set(mancoregvar.htoggle_on,'value',1);
	
        else
            set(mancoregvar.htoggle_off,'value',0);
            mancoregvar.sourceimage=st.vols{2}; % Backup current state
            st.vols{2}=st.vols{1};
            st.vols{2}.ax=mancoregvar.sourceimage.ax;   % These have to stay the same
            st.vols{2}.window=mancoregvar.sourceimage.window;
            st.vols{2}.area=mancoregvar.sourceimage.area;
            spm_orthviews('redraw');
        end        
        
        return
	end
	
% 'reset'
% Resets transformation matrix
%--------------------------------------------------------------------------

if strcmp(op,'reset'), 
       
        set(mancoregvar.hpitch,'Value',0);
        set(mancoregvar.hroll,'Value',0);
        set(mancoregvar.hyaw,'Value',0);
	
        set(mancoregvar.hx,'Value',0);
        set(mancoregvar.hy,'Value',0);
        set(mancoregvar.hz,'Value',0);
         
        set(mancoregvar.hpitch_val,'string','0');
        set(mancoregvar.hroll_val,'string','0');
        set(mancoregvar.hyaw_val,'string','0');
	
        set(mancoregvar.hx_val,'string','0');
        set(mancoregvar.hy_val,'string','0');
        set(mancoregvar.hz_val,'string','0');

        mancoregvar.sourceimage.premul=spm_matrix([0 0 0 0 0 0 1 1 1 0 0 0]);
        if (get(mancoregvar.htoggle_on,'value')==0) % source is currently displayed
        st.vols{2}.premul=spm_matrix([0 0 0 0 0 0 1 1 1 0 0 0]);    
        end
        
        plotmat;
        spm_orthviews('redraw');
                
        
        return
	end

    
% 'apply'
% Apply transformation to a selected set of images
%--------------------------------------------------------------------------

if strcmp(op,'apply'),      
        
        angl_pitch=get(mancoregvar.hpitch,'Value');
        angl_roll=get(mancoregvar.hroll,'Value');
        angl_yaw=get(mancoregvar.hyaw,'Value');
	
        dist_x=get(mancoregvar.hx,'Value');
        dist_y=get(mancoregvar.hy,'Value');
        dist_z=get(mancoregvar.hz,'Value');
	    spm_defaults;
        mat = spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);
		
        % The following is copied from spm_image.m
        if det(mat)<=0                           
			spm('alert!','This will flip the images',mfilename,0,1);
		end;
		P = spm_select(Inf, 'image','Images to reorient');
        
        
        DateFormat = 'yyyy_mm_dd_HH_MM';
        M=mat; %#ok<NASGU>
        SavedMat = fullfile(pwd, strcat('ReorientMatrix_', datestr(now, DateFormat), '.mat'));
        fprintf(['Saving reorient matrice to ' SavedMat '.\n']);
        save(SavedMat,'M', 'P');
        clear M DateFormat SavedMat
        
        
        		
        %fprintf('Skipping image selection! Preselected images ...\n');
        %load d:\mrdata\functional\prediction\v1_chris\P.mat
        
        Mats = zeros(4,4,size(P,1));

 		for i=1:size(P,1)
            tmp = sprintf('Reading current orientations... %.0f%%.\n', i/size(P,1)*100 );
            fprintf('%s',tmp)
            
			Mats(:,:,i) = spm_get_space(P(i,:));
			spm_progress_bar('Set',i);
            
            fprintf('%s',char(sign(tmp)*8))
		end;
        
              
		for i=1:size(P,1)
            tmp = sprintf('Reorienting images... %.0f%%.\n', i/size(P,1)*100 );
            fprintf('%s',tmp)
            
			spm_get_space(P(i,:),mat*Mats(:,:,i));
			
            fprintf('%s',char(sign(tmp)*8))
		end;
        
		
		tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
		if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
			spm_image('init',st.vols{1}.fname);
		end;
		return;
	end;
	

% 'plotmat'
% Plot matrix notation of transformation
%--------------------------------------------------------------------------

if strcmp(op,'plotmat'),      
        
        plotmat;
        return
end
    
% None of the op strings matches

fprintf('WARNING: mancoreg_callbacks.m called with unspecified operation!\n');

return;



function plotmat;

global st mancoregvar;

        angl_pitch=get(mancoregvar.hpitch,'Value');
        angl_roll=get(mancoregvar.hroll,'Value');
        angl_yaw=get(mancoregvar.hyaw,'Value');
	
        dist_x=get(mancoregvar.hx,'Value');
        dist_y=get(mancoregvar.hy,'Value');
        dist_z=get(mancoregvar.hz,'Value');
        
        premul=spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]);

        set(mancoregvar.hmat_1_1,'string',sprintf('%2.4g',(premul(1,1)) ));
        set(mancoregvar.hmat_1_2,'string',sprintf('%2.4g',(premul(1,2)) ));
        set(mancoregvar.hmat_1_3,'string',sprintf('%2.4g',(premul(1,3)) ));
        set(mancoregvar.hmat_1_4,'string',sprintf('%2.4g',(premul(1,4)) ));
        set(mancoregvar.hmat_2_1,'string',sprintf('%2.4g',(premul(2,1)) ));
        set(mancoregvar.hmat_2_2,'string',sprintf('%2.4g',(premul(2,2)) ));
        set(mancoregvar.hmat_2_3,'string',sprintf('%2.4g',(premul(2,3)) ));
        set(mancoregvar.hmat_2_4,'string',sprintf('%2.4g',(premul(2,4)) ));
        set(mancoregvar.hmat_3_1,'string',sprintf('%2.4g',(premul(3,1)) ));
        set(mancoregvar.hmat_3_2,'string',sprintf('%2.4g',(premul(3,2)) ));
        set(mancoregvar.hmat_3_3,'string',sprintf('%2.4g',(premul(3,3)) ));
        set(mancoregvar.hmat_3_4,'string',sprintf('%2.4g',(premul(3,4)) ));
        set(mancoregvar.hmat_4_1,'string',sprintf('%2.4g',(premul(4,1)) ));
        set(mancoregvar.hmat_4_2,'string',sprintf('%2.4g',(premul(4,2)) ));
        set(mancoregvar.hmat_4_3,'string',sprintf('%2.4g',(premul(4,3)) ));
        set(mancoregvar.hmat_4_4,'string',sprintf('%2.4g',(premul(4,4)) ));
        
        
 return;
        

