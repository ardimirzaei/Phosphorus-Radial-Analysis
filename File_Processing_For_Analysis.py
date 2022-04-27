# -*- coding: utf-8 -*-
"""
Created on Fri Mar 25 14:10:48 2022

@author: Ardi
"""

# Imports
import os
import pandas as pd
# import numpy as np
import re
from glob import glob
from tqdm import tqdm

#%%

# Functions

def extract_info_from_outfile(file_number, _folder, _compound, _alpha_value, atom_headers = None):
    if atom_headers == None:
        atom_headers = ['ATOM','MONOPOLE','KAPPA','KAPPA_HAT','NET CHARGE']
    
    file_location = f'{_folder}/{_compound}/{_alpha_value}'

    with open(f'{file_location}/xd_stat.out.{file_number}') as f:
        lines = f.readlines()
        _start = [t for t, c in enumerate(bool(re.search('TABLE 1',i)) for i in lines) if c][0]
        _end = [t for t, c in enumerate(bool(re.search('SUM',i)) for i in lines) if c][0]
        table_text = lines[_start:_end]
        # Search through each line until finding the table
        table_text = table_text[5:-1]
        atom_info = []
        for line in table_text:
            # Extract table information individually
            _atom = line[0:16].strip(' ')[0] # Change this when you start working with element more than single
            _monopole = float(re.findall('\d\.\d{0,4}',line[16:31].strip(' '))[0])
            _kappa = float(re.findall('\d\.\d{0,4}',line[31:48].strip(' '))[0])
            _kappa_hat = float(re.findall('\d\.\d{0,4}',line[48:61].strip(' '))[0])
            _netcharge = line[61:70].strip(' ') # not manipulating this yet to a number
            atom_info.append([_atom, _monopole,_kappa,_kappa_hat, _netcharge])

        atom_info = pd.DataFrame(atom_info, columns=atom_headers)
        atom_info['N'] = file_number
        atom_info['drug'] = _folder
        atom_info['compound'] = _compound
        atom_info['alphavalue'] = _alpha_value
        f.close()

        return(atom_info)


#%%

def explore_and_build_table():
    all_bestnls = []
    all_atom_info = []
    pbar = tqdm(glob('DataFiles/Phos*'),leave = True, position = 0)
    all_bestnls, all_atom_info = loop_through_folders(pbar, all_atom_info, all_bestnls)
    # Because of MOSS folder
    print("Searching Through MOSS Folder")
    pbar = tqdm(glob('DataFiles/MOSS/Phos*'),leave = True, position = 0)
    all_bestnls, all_atom_info = loop_through_folders(pbar, all_atom_info, all_bestnls)

    return all_bestnls, all_atom_info

#%%

def loop_through_folders(pbar, all_atom_info, all_bestnls):
    for _folder in pbar:
        if os.path.isdir(_folder):
            for _compound in os.listdir(_folder):
                if os.path.isdir(f'{_folder}/{_compound}'):
                    for _alpha_value in os.listdir(f'{_folder}/{_compound}'):
                        file_location = f'{_folder}/{_compound}/{_alpha_value}'
                        pbar.set_description(f'{_folder}/{_compound}/{_alpha_value}')
                        try:
                            bestnl = pd.read_csv(f'{file_location}/bestnl.csv')
                            bestnl['drug'] = _folder
                            bestnl['compound'] = _compound
                            bestnl['alphavalue'] = _alpha_value
                            all_bestnls.append(bestnl)

                            for _std_file in glob(f'{file_location}/xd_stat.out.*'):
                                pbar.set_description(f'Processing: {_std_file}')
                                file_number = int(re.findall('\d{0,3}$',_std_file)[0])
                                atom_info = extract_info_from_outfile(file_number, _folder, _compound, _alpha_value)
                                all_atom_info.append(atom_info)

                        except:
                            pass
    return all_bestnls, all_atom_info

def export_files():
    print("Building All Best Nls")
    clean_bestnls = all_bestnls[0]
    # pbar = tqdm(range(1,len(all_bestnls)),leave = True, position = 0)
    
    clean_bestnls = pd.concat(all_bestnls, axis=0)
    
    # for nl in pbar:
    #     pbar.set_description('Clean Best NL File')
    #     pd.concat(all_bestnls, axis=1)
    #     clean_bestnls = pd.concat((clean_bestnls, all_bestnls[nl]))
    
    clean_bestnls.reset_index(inplace=True)
    
    # clean_atom_info= all_atom_info[0]
    # pbar = tqdm(range(1,len(all_atom_info)),leave = True, position = 0)
    # for ai in pbar:
    #     pbar.set_description('Clean Atom File')
    #     clean_atom_info = pd.concat((clean_atom_info, all_atom_info[ai]))
    print("Building All Atom Info")
    clean_atom_info = pd.concat(all_atom_info, axis=0)
    clean_atom_info.reset_index(inplace=True)
    
    print("Exporting Files")

    clean_bestnls.to_csv('FileMergeOutput/Complete_Best_Nls.csv', index = False)
    clean_atom_info.to_csv('FileMergeOutput/Complete_Atom_Info.csv', index = False)

#%%

# Merge Datasets
def merge_and_export():

    clean_bestnls = pd.read_csv('FileMergeOutput/Complete_Best_Nls.csv')
    clean_atom_info = pd.read_csv('FileMergeOutput/Complete_Atom_Info.csv')
    clean_atom_info.drop_duplicates(subset=['ATOM','KAPPA','KAPPA_HAT','N','drug','compound','alphavalue'], inplace = True)
    print('Merging Datasets')
    full_data_frame = clean_bestnls.merge(clean_atom_info, left_on=['N','drug','compound','alphavalue'], right_on=['N','drug','compound','alphavalue'])
    # print(full_data_frame.head())
    print("Exporting Merge File")
    full_data_frame.corr()
    full_data_frame.to_csv('FileMergeOutput/Full_DataFrame_nl_Atoms.csv')

#%%

if __name__ == "__main__":
    all_bestnls, all_atom_info = explore_and_build_table()
    export_files()
    merge_and_export()


