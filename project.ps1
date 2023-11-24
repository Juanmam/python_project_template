##### READ .ENV #####

function setup_env {
    param ()

    $envFilePath = ".\env\project.env"

    # Check if the file exists
    if (Test-Path $envFilePath) {
        # Read the file line by line
        $envFileLines = Get-Content $envFilePath

        # Loop through each line
        foreach ($line in $envFileLines) {
            # Split the line into key and value
            $keyValue = $line -split "=", 2

            # Check if the split resulted in two parts (key and value)
            if ($keyValue.Length -eq 2) {
                # Create a new variable with the key name and assign the value to it in the global scope
                Set-Variable -Name $keyValue[0].Trim() -Value $keyValue[1].Trim() -Scope Global -Force
            }
        }
    } else {
        Write-Host "The .env file was not found at $envFilePath"
    }
}


##### Setup virtual environment #####

function setup_venv {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PYTHON_VERSION
    )

    $venvPath = ".\.venv"

    if (Test-Path variable:PYTHON_VERSION) {
        if (-not (Test-Path $venvPath)){
            Write-Host "PYTHON_VERSION is $PYTHON_VERSION"
    
            # Create a virtual environment in the current directory
            
            python -m venv $venvPath
            .\.venv\Scripts\Activate.ps1
        
            Write-Host "Virtual environment created at $venvPath with Python version $PYTHON_VERSION"
        }
    } else {
        Write-Host "PYTHON_VERSION variable is not set in the .env file"
    }
}


##### DOCUMENTATION FRAMEWORKS #####

function setup_sphinx {
    # Install Sphinx
    pip install sphinx

    # Create a documentation directory
    $docsDir = ".\docs"
    if (-not (Test-Path -Path $docsDir)) {
        New-Item -ItemType Directory -Path $docsDir
    }
    Set-Location $docsDir

    # Initialize Sphinx
    sphinx-quickstart

    Write-Host "Sphinx documentation setup is complete."
}

function setup_mkdocs {
    # Install mkdocs
    pip install mkdocs

    # Install Material theme for mkdocs
    pip install mkdocs-material

    # Create a documentation directory
    $docsDir = ".\docs"
    if (-not (Test-Path -Path $docsDir)) {
        New-Item -ItemType Directory -Path $docsDir
    }
    Set-Location $docsDir

    # Initialize MkDocs
    mkdocs new .

    Write-Host "MkDocs documentation setup is complete."
}

function setup_docusaurus {
    # Check if npm is installed
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm is not installed. Please install Node.js (which includes npm)."
        return
    }

    # Check if npx is installed
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
        Write-Host "npx is not installed. Please install Node.js (which includes npx)."
        return
    }

    # Install Yarn - Docusaurus requires Yarn
    npm install --global yarn

    # Create a documentation directory
    $docsDir = ".\docs"
    if (-not (Test-Path -Path $docsDir)) {
        New-Item -ItemType Directory -Path $docsDir
    }
    Set-Location $docsDir

    # Initialize Docusaurus
    npx create-docusaurus@latest $docsDir classic

    Write-Host "Docusaurus documentation setup is complete."
}

function setup_blank_doc { # TODO
    # Create a documentation directory
    $docsDir = ".\docs"
    if (-not (Test-Path -Path $docsDir)) {
        New-Item -ItemType Directory -Path $docsDir
    }

    Write-Host "Documentation setup is complete."
}


##### PARSING ARGUMENTS #####

function help { # TODO
    Write-Host "This is going to be a manual, we will work on it later."
}


function init{
    param (
        [Parameter(Mandatory=$false)]
        [string]$pyver = 3.9.0,

        [Parameter(Mandatory=$false)]
        [ValidateSet("sphinx", "mkdocs", "docusaurus", "blank")]
        [string]$doc = "blank"
    )
    # Read environment variables from .env
    setup_env

    # Setup the .venv for the given Python version. 
    setup_venv -PYTHON_VERSION $PYTHON_VERSION

    Write-Host $doc

    # Build documentation
    if ($doc -eq "sphinx"){
        setup_sphinx
    } elseif ($doc -eq "mkdocs") {
        setup_mkdocs
    } elseif ($doc -eq "docusaurus") {
        setup_docusaurus
    } else {
        setup_blank_doc
    }
}

init -doc 'sphinx'
