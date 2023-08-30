% Fx_dipfit_save() - dipole fitting based on spatial patterns interpreted
%                    from compact CNN 

% Input: 
%   spa_arr      - spatial pattern interpreted from compact CNN (NXM 2-D array)
%                  The spatial pattern will be used for dipole fitting
%                 => N denotes number of convolutional filters (our case: 800)
%                 => M denotes number of EEG channels (our case: 64)
%   sub_size     - the number of subjects (our case: 52)
%   bad_sub      - 1-D array representing the number of subjects (our case has two bad subjects - subject29, subject34)
%   data_path    - path which includes data (The EEGlab dataset containing the dipole fitting results must be saved in the dipfit folder in data_path)
%   matlab path  - mMtlab folder path 

% Outputs:
%   STUDY        - a new STUDY set containing some or all of the datasets in ALLEEG, 
%                 plus additional information from the optional inputs above. 
%   ALLEEG       - a vector of EEG datasets included in the STUDY structure 

% This file is based on EEGLAB, see http://www.eeglab.org
% for the documentation and details.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

function Fx_dipfit_save(spa_arr, sub_size, bad_sub, data_path, matlab_path)
    
    eeg_raw_path=[data_path, 'eeg_raw\'];
    eeg_dipfit_path=[data_path, 'eeg_dipfit\'];
    sub_cnt_wobad=0;
    num_sub_wo_bad=sub_size-length(bad_sub);
    n_comps=round(length(spa_arr)/num_sub_wo_bad);

    if ~exist(eeg_dipfit_path, 'dir')
       mkdir(eeg_dipfit_path)
    end

    for sub_cnt=1:sub_size
        if ~ismember(sub_cnt,bad_sub)
            sub_cnt_wobad=sub_cnt_wobad+1;
            if sub_cnt<10
                sub_code=['0', num2str(sub_cnt)];
            else
                sub_code=num2str(sub_cnt);
            end

            file_name=['s', sub_code, '.set'];
            EEG = pop_loadset('filename',file_name,'filepath',eeg_raw_path);
            [ch_size, ~, ~]=size(EEG.data);

            spa_sidx=(sub_cnt_wobad-1)*n_comps+1;
            spa_fidx=(sub_cnt_wobad)*n_comps;

            EEG.icasphere=eye(ch_size);
            EEG.icaweights=spa_arr(spa_sidx:spa_fidx,:);
            EEG.icawinv=spa_arr(spa_sidx:spa_fidx,:)';

            EEG = pop_dipfit_settings( EEG, 'hdmfile',[matlab_path, 'toolbox\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\standard_vol.mat'],'coordformat','MNI','mrifile',[matlab_path, 'toolbox\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat'],'chanfile',[matlab_path, 'toolbox\\eeglab2021.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc'],'coord_transform',[0.662 -16.047 -1.9632 0.082722 0.0022919 -1.5729 100.3391 91.1309 101.3671] ,'chansel',[1:64] );
            EEG = pop_multifit(EEG, [] ,'threshold',100);

            fname=['s', sub_code, '.set'];
            EEG = pop_saveset( EEG, 'filename',fname,'filepath',eeg_dipfit_path);

            close all;
        end
    end

end