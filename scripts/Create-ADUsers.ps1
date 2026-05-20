<#
.SYNOPSIS
    Création automatisée d'utilisateurs Active Directory avec placement
    dans une OU et affectation à un groupe de sécurité.

.DESCRIPTION
    Ce script provisionne des comptes utilisateurs dans Active Directory.
    Il propose un menu interactif pour choisir l'OU de destination et le
    groupe de sécurité, génère le UserPrincipalName automatiquement, force
    le changement de mot de passe à la première connexion, et journalise
    chaque opération.

    Environnement cible : domaine cmc.local
    OUs disponibles : ADMIN, COMP, GESTION, IT

.NOTES
    Auteur  : Douae Karachi
    Projet  : Lab Active Directory - Infrastructure d'entreprise
    Requis  : Module ActiveDirectory (RSAT), exécution sur un contrôleur de domaine
              ou une machine d'administration avec les droits adéquats.
#>

# ============================================================
#  PARAMÈTRES GLOBAUX
# ============================================================

$Domaine     = "cmc.local"
$DomaineDN   = "DC=cmc,DC=local"

# Liste des OUs disponibles (doivent exister dans l'AD)
$OUsDisponibles = @{
    1 = "OU=ADMIN,$DomaineDN"
    2 = "OU=COMP,$DomaineDN"
    3 = "OU=GESTION,$DomaineDN"
    4 = "OU=IT,$DomaineDN"
}

# Liste des groupes de sécurité disponibles
$GroupesDisponibles = @{
    1 = "admin"
    2 = "dev"
    3 = "tech"
    4 = "soc"
    5 = "assistant"
    6 = "finance"
    7 = "client"
    8 = "analytic"
}

# ============================================================
#  FONCTIONS UTILITAIRES
# ============================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Niveau = "INFO"
    )
    $horodatage = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $couleur = switch ($Niveau) {
        "INFO"    { "White" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$horodatage] [$Niveau] $Message" -ForegroundColor $couleur
}

function Show-Menu {
    param(
        [hashtable]$Options,
        [string]$Titre
    )
    Write-Host "`n$Titre" -ForegroundColor Cyan
    foreach ($cle in ($Options.Keys | Sort-Object)) {
        Write-Host "  $cle. $($Options[$cle])"
    }
}

# ============================================================
#  VÉRIFICATION DES PRÉREQUIS
# ============================================================

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Log "Le module ActiveDirectory n'est pas installé. Installez RSAT." "ERROR"
    exit 1
}
Import-Module ActiveDirectory

# ============================================================
#  SAISIE DES INFORMATIONS UTILISATEUR
# ============================================================

Write-Host "`n=================================================="
Write-Host "   CRÉATION D'UN UTILISATEUR ACTIVE DIRECTORY"
Write-Host "==================================================`n"

$Prenom = Read-Host "Prénom de l'utilisateur"
$Nom    = Read-Host "Nom de l'utilisateur"

# Construction du nom de connexion : première lettre du prénom + nom (en minuscules)
$SamAccountName = ($Prenom.Substring(0,1) + $Nom).ToLower() -replace '\s',''
$UserPrincipalName = "$SamAccountName@$Domaine"
$NomComplet = "$Prenom $Nom"

# Mot de passe temporaire (sera changé à la première connexion)
$MotDePasse = Read-Host "Mot de passe temporaire" -AsSecureString

# ============================================================
#  CHOIX DE L'OU DE DESTINATION
# ============================================================

Show-Menu -Options $OUsDisponibles -Titre "Choisissez l'OU de destination :"
$choixOU = Read-Host "`nNuméro de l'OU"

if (-not $OUsDisponibles.ContainsKey([int]$choixOU)) {
    Write-Log "Choix d'OU invalide." "ERROR"
    exit 1
}
$OUCible = $OUsDisponibles[[int]$choixOU]

# ============================================================
#  CHOIX DU GROUPE DE SÉCURITÉ (OPTIONNEL)
# ============================================================

Show-Menu -Options $GroupesDisponibles -Titre "Choisissez un groupe (0 pour aucun) :"
$choixGroupe = Read-Host "`nNuméro du groupe"

# ============================================================
#  CRÉATION DE L'UTILISATEUR
# ============================================================

try {
    # Vérifier si l'utilisateur existe déjà
    $existe = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue
    if ($existe) {
        Write-Log "L'utilisateur '$SamAccountName' existe déjà. Abandon." "WARNING"
        exit 1
    }

    New-ADUser `
        -Name                 $NomComplet `
        -GivenName            $Prenom `
        -Surname              $Nom `
        -SamAccountName       $SamAccountName `
        -UserPrincipalName    $UserPrincipalName `
        -AccountPassword      $MotDePasse `
        -Path                 $OUCible `
        -Enabled              $true `
        -ChangePasswordAtLogon $true

    Write-Log "Utilisateur '$NomComplet' créé dans $OUCible" "SUCCESS"
    Write-Log "Identifiant de connexion : $UserPrincipalName" "INFO"
}
catch {
    Write-Log "Erreur lors de la création : $_" "ERROR"
    exit 1
}

# ============================================================
#  AFFECTATION AU GROUPE (SI CHOISI)
# ============================================================

if ($choixGroupe -ne "0" -and $GroupesDisponibles.ContainsKey([int]$choixGroupe)) {
    $groupe = $GroupesDisponibles[[int]$choixGroupe]
    try {
        Add-ADGroupMember -Identity $groupe -Members $SamAccountName
        Write-Log "Utilisateur ajouté au groupe '$groupe'" "SUCCESS"
    }
    catch {
        Write-Log "Impossible d'ajouter au groupe '$groupe' : $_" "WARNING"
    }
}

Write-Host "`n=================================================="
Write-Log "Provisionnement terminé." "SUCCESS"
Write-Host "==================================================`n"
