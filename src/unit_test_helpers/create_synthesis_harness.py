#!/usr/bin/env python3

import sys
import os
import re

CUR_DIR = os.path.dirname(os.path.abspath(__file__))
CVA6_ROOT = os.path.join(CUR_DIR, "../../cva6_ariane")

def get_all_files_in_dir(directory, extensions=('.sv', '.svh')):
    if not os.path.exists(directory):
        print(f"Error: Directory {directory} does not exist.")
        return []
        
    all_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(extensions):
                all_files.append(os.path.abspath(os.path.join(root, file)))
    return all_files

def get_testbench_dependencies(RTL_DIR, flist):
    if not os.path.exists(RTL_DIR):
        print(f"Error: RTL directory {RTL_DIR} does not exist.")
        sys.exit(1)

    flist_path = os.path.join(RTL_DIR, flist)
    if not os.path.exists(flist_path):
        print(f"Error: File list {flist_path} does not exist.")
        sys.exit(1)
        
    with open(flist_path, 'r') as file:
        dependencies_list = file.readlines()
        
        inc_dirs = [line.split("+incdir+")[1].strip() for line in dependencies_list if line.startswith("+incdir+")]
        print(f"Found {len(inc_dirs)} include directories: {inc_dirs}")

        for dir in inc_dirs:
            all_files = get_all_files_in_dir(dir)
            dependencies_list.extend(all_files)

        if (not 'aes' in flist):
            dependencies_list += [f for f in get_all_files_in_dir(RTL_DIR) if '_lite_' in f ]
            cleaned_dependencies = [dep.strip() for dep in dependencies_list if dep.strip() and not dep.startswith("+incdir+")]
            cleaned_dependencies = list(set(cleaned_dependencies))
            for f in cleaned_dependencies:
                if 'test' in os.path.basename(f):
                    print(f"Removing testbench file: {f}")
                    cleaned_dependencies.remove(f)
            return cleaned_dependencies
        else:
            dependencies_list = [dep.strip() for dep in dependencies_list if dep.strip()]
            remove_duplicates_with_order = []
            for dep in dependencies_list:
                if dep not in remove_duplicates_with_order:
                    remove_duplicates_with_order.append(dep)

            return remove_duplicates_with_order

def get_cva6_ptw_dependencies():
    dependencies = []
    include_dir = os.path.join(CVA6_ROOT, "core", "include")
    include_files = [
        "riscv_pkg.sv",
        "config_pkg.sv", 
        "ariane_pkg.sv",
        "cv64a6_imafdc_sv39_config_pkg.sv"
    ]
    
    for inc_file in include_files:
        file_path = os.path.join(include_dir, inc_file)
        if os.path.exists(file_path):
            dependencies.append(file_path)
        else:
            print(f"Warning: Include file {file_path} not found")
    
    pmp_dir = os.path.join(CVA6_ROOT, "core", "pmp", "src")
    pmp_files = ["pmp.sv", "pmp_entry.sv"]
    
    for pmp_file in pmp_files:
        file_path = os.path.join(pmp_dir, pmp_file)
        if os.path.exists(file_path):
            dependencies.append(file_path)
        else:
            print(f"Warning: PMP file {file_path} not found")
    
    mmu_dir = os.path.join(CVA6_ROOT, "core", "cva6_mmu")
    
    anvil_ptw_files = get_all_files_in_dir(mmu_dir)
    for file_path in anvil_ptw_files:
        if "anvil_ptw.sv" in os.path.basename(file_path) and "cva6_anvil_ptw.sv" not in os.path.basename(file_path):
            dependencies.append(file_path)
            break
    
    return dependencies

def find_module_dependencies(file_path):
    if not os.path.exists(file_path):
        return []
    
    dependencies = []
    
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    module_pattern = r'(\w+)\s+(?:#\([^)]*\))?\s*(\w+)\s*\('
    matches = re.findall(module_pattern, content)
    
    for match in matches:
        module_name = match[0]
    
        if module_name in ['assign', 'always', 'initial', 'generate', 'if', 'else', 'case', 'for', 'while']:
            continue
        
    
        module_file = find_module_file(module_name)
        if module_file and module_file not in dependencies:
            dependencies.append(module_file)
    
    return dependencies

def find_module_file(module_name):
    
    search_dirs = [
        os.path.join(CVA6_ROOT, "core"),
        os.path.join(CVA6_ROOT, "core", "pmp", "src"),
        os.path.join(CVA6_ROOT, "core", "cva6_mmu"),
        os.path.join(CVA6_ROOT, "core", "include")
    ]
    
    for search_dir in search_dirs:
        if not os.path.exists(search_dir):
            continue
            
        sv_files = get_all_files_in_dir(search_dir)
        for file_path in sv_files:
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
    
                module_pattern = rf'^\s*module\s+{module_name}\s*[#(;]'
                if re.search(module_pattern, content, re.MULTILINE):
                    return file_path
            except:
                continue
    
    return None

def get_cva6_dependencies_for_module(target_file):
    
    if not os.path.exists(target_file):
        print(f"Error: Target file {target_file} does not exist.")
        return []
    
    print(f"Analyzing CVA6 module dependencies for: {target_file}")
    
    # Get base dependencies
    dependencies = get_cva6_ptw_dependencies()
    
    # Add the target file
    dependencies.append(target_file)
    
    # Find additional dependencies by parsing files
    all_deps = dependencies.copy()
    processed = set()
    to_process = dependencies.copy()
    
    while to_process:
        current_file = to_process.pop(0)
        if current_file in processed:
            continue
        
        processed.add(current_file)
        
    
        file_deps = find_module_dependencies(current_file)
        for dep in file_deps:
            if dep not in all_deps:
                all_deps.append(dep)
                to_process.append(dep)
    
    
    unique_deps = []
    for dep in all_deps:
        if dep not in unique_deps:
            unique_deps.append(dep)
    
    return unique_deps

def sort_dependencies(dependencies, is_cva6=False):
    
    if is_cva6:
    
        packages = []
        modules = []
        
        for dep in dependencies:
            filename = os.path.basename(dep)
            if filename.endswith('.svh') or 'pkg' in filename:
                packages.append(dep)
            else:
                modules.append(dep)
        
        # Sort packages by dependency order
        package_order = [
            'riscv_pkg.sv',
            'config_pkg.sv', 
            'cv64a6_imafdc_sv39_config_pkg.sv',
            'ariane_pkg.sv'
        ]
        
        sorted_packages = []
        for pkg_name in package_order:
            for pkg in packages:
                if pkg_name in os.path.basename(pkg):
                    sorted_packages.append(pkg)
                    break
        
    
        for pkg in packages:
            if pkg not in sorted_packages:
                sorted_packages.append(pkg)
        
        return sorted_packages + modules
    else:
    
        dependencies.sort(key=lambda x: (not ((x.endswith('.svh')) or ('pkg' in os.path.basename(x))), x))
        return dependencies

def preprocess_files(file):
    
    if not os.path.exists(file):
        print(f"Error: File {file} does not exist.")
        sys.exit(1)
    
    try:
        with open(file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
    
        content = re.sub(r'^(\s*`include)', r'// \1', content, flags=re.MULTILINE)
        
        return content
    except Exception as e:
        print(f"Error reading file {file}: {e}")
        return ""

def create_synthesis_harness(dependencies_list, testbench_name, is_cva6=False, target_file=None):
    
    
    
    dependencies_list = sort_dependencies(dependencies_list, is_cva6)
    
    
    if not is_cva6 and not 'aes' in testbench_name:
        pass
    
    
    SRC_DIR = os.path.join(CUR_DIR, "../build")
    os.makedirs(SRC_DIR, exist_ok=True)
    SYNTH_DIR = os.path.join(SRC_DIR, testbench_name.split('.')[0])
    if os.path.exists(SYNTH_DIR):
        print(f"Warning: Directory {SYNTH_DIR} already exists. It will be overwritten.")
        os.system(f"rm -rf {SYNTH_DIR}")
    os.makedirs(SYNTH_DIR, exist_ok=True)
    os.makedirs(os.path.join(SYNTH_DIR, "rtl"), exist_ok=True)
    print(f"Synthesis directory created at: {SYNTH_DIR}")
    
    output_file = os.path.join(SYNTH_DIR, "rtl", testbench_name)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        if is_cva6:
            # CVA6-specific header
            f.write(f"""/*
 * CVA6 Synthesis Harness
 * Target: {os.path.basename(target_file) if target_file else testbench_name}
 * Configuration: CV64A6 IMAFDC SV39
 * Generated: {testbench_name}
 * 
 * This file contains all dependencies for synthesis.
 */


""")
        
        # Process each dependency
        for dep in dependencies_list:
            content = preprocess_files(dep)
            
            if is_cva6:
                # CVA6-style formatting
                f.write(f"//==============================================================================\n")
                f.write(f"// File: {os.path.relpath(dep, CVA6_ROOT)}\n")
                f.write(f"//==============================================================================\n\n")
            else:
                # Original formatting
                f.write(f"//=========================File: {os.path.basename(dep)}================\n")
            
            f.write(content)
            f.write(f"\n\n")
        
     
    
    file_size = os.path.getsize(output_file)
    print(f"File size: {file_size:,} bytes")
    
    with open(output_file, 'r') as f:
        line_count = sum(1 for _ in f)
    print(f"Line count: {line_count:,} lines")
    
    if is_cva6:
        print(f"Contains {len(dependencies_list)} dependency files")
    
    return output_file

def detect_project_type(target_file=None, rtl_dir=None, flist=None):
    
    if target_file:
        if 'cva6' in target_file.lower() or 'core/cva6_mmu' in target_file:
            return 'cva6'
        if os.path.exists(os.path.join(CVA6_ROOT, "core", "include", "riscv_pkg.sv")):
            return 'cva6'
    
    if os.path.exists(os.path.join(os.path.dirname(CUR_DIR), "core", "include", "riscv_pkg.sv")):
        return 'cva6'
    
    return 'case_study'

def main():
    
    if len(sys.argv) < 2:
        print("Usage: python create_synthesis_harness.py <testbench_path> <file_list> testbench_name ")
        print("Or: python create_synthesis_harness.py <target_file> [output_name]")

        sys.exit(1)
    
    
    if len(sys.argv) == 2 or (len(sys.argv) == 3 and not os.path.isdir(sys.argv[1])):
        target_file = sys.argv[1]
        
        
        if not os.path.isabs(target_file):
            target_file = os.path.join(CVA6_ROOT, target_file)
        
        
        if len(sys.argv) > 2:
            output_name = sys.argv[2]
        else:
            base_name = os.path.basename(target_file).replace('.sv', '')
            output_name = f"{base_name}_synthesis.sv"
        
        print(f"CVA6: Creating synthesis harness for {target_file}")
        
        
        dependencies_list = get_cva6_dependencies_for_module(target_file)
        
        print(f"Found {len(dependencies_list)} total dependencies:")
        for i, dep in enumerate(dependencies_list):
            print(f"  {i+1:2d}. {os.path.relpath(dep, CVA6_ROOT)}")
        
        if not dependencies_list:
            print("No dependencies found for the module.")
            sys.exit(1)
        
        
        output_file = create_synthesis_harness(dependencies_list, output_name, is_cva6=True, target_file=target_file)
        print(f"\nCVA6 synthesis harness created successfully!")
        print(f"Output file: {os.path.relpath(output_file, CVA6_ROOT)}")
        
    elif len(sys.argv) == 4:
        
        testbench_path = sys.argv[1]
        rtl_path = os.path.abspath(testbench_path)
        flist = sys.argv[2]
        testbench_name = sys.argv[3] + ".sv"
        
        print(f"Case Study Mode: Creating synthesis harness for {testbench_name}")
        
        
        dependencies_list = get_testbench_dependencies(rtl_path, flist)
        
        print(f"Found {len(dependencies_list)} dependencies for the testbench.")
        
        if not dependencies_list:
            print("No dependencies found for the testbench.")
            sys.exit(1)
        
        
        create_synthesis_harness(dependencies_list, testbench_name, is_cva6=False)
        print("Case study synthesis harness created successfully.")
        
    else:
        print("Error: Invalid number of arguments.")
        print("Use --help or run without arguments to see usage information.")
        sys.exit(1)

if __name__ == "__main__":
    main()
    

# move config packages to the top include build config include mmu and cva6 definitions of dcache interface create build config and then remove parameters as argument from main mmu code
# define them as localparams in ariane pkg which is imported by all modules