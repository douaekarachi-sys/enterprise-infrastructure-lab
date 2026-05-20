<#
.SYNOPSIS
    Configuration automatisée de scopes DHCP multiples pour une
    infrastructure réseau segmentée (VLAN par service).

.DESCRIPTION
    Ce script crée plusieurs scopes DHCP correspondant aux différents
    segments réseau de l'entreprise (Gestion, IT, DMZ, COMP, pfSense, Admin).
    Pour chaque scope, il définit la plage d'adresses, le masque de
    sous-réseau, la passerelle et le serveur DNS.

    Environnement cible : Windows Server avec rôle DHCP installé
    Schéma d'adressage : 10.0.0.0 segmenté en sous-réseaux /28 et /29

.NOTES
    Auteur  : Douae Karachi
    Projet  : Lab Infrastructure Réseau - Configuration DHCP
    Requis  : Rôle DHCP installé et autorisé dans Active Directory.
              Module DhcpServer disponible.
#>

# ============================================================
#  DÉFINITION DES SCOPES
# ============================================================
# Chaque scope représente un segment réseau dédié à un service.
# Masque /28 = 255.255.255.240 (14 hôtes utilisables)
# Masque /29 = 255.255.255.248 (6 hôtes utilisables)

$Scopes = @(
    @{
        Nom        = "Gestion"
        ScopeID    = "10.0.0.0"
        Debut      = "10.0.0.1"
        Fin        = "10.0.0.14"
        Masque     = "255.255.255.240"
        Passerelle = "10.0.0.1"
        DNS        = "10.0.0.50"
    },
    @{
        Nom        = "IT"
        ScopeID    = "10.0.0.32"
        Debut      = "10.0.0.33"
        Fin        = "10.0.0.46"
        Masque     = "255.255.255.240"
        Passerelle = "10.0.0.33"
        DNS        = "10.0.0.50"
    },
    @{
        Nom        = "DMZ"
        ScopeID    = "10.0.0.48"
        Debut      = "10.0.0.49"
        Fin        = "10.0.0.62"
        Masque     = "255.255.255.240"
        Passerelle = "10.0.0.49"
        DNS        = "10.0.0.50"
    },
    @{
        Nom        = "COMP"
        ScopeID    = "10.0.0.64"
        Debut      = "10.0.0.65"
        Fin        = "10.0.0.78"
        Masque     = "255.255.255.240"
        Passerelle = "10.0.0.65"
        DNS        = "10.0.0.50"
    },
    @{
        Nom        = "pfSense"
        ScopeID    = "10.0.0.80"
        Debut      = "10.0.0.81"
        Fin        = "10.0.0.94"
        Masque     = "255.255.255.240"
        Passerelle = "10.0.0.81"
        DNS        = "10.0.0.50"
    },
    @{
        Nom        = "Admin"
        ScopeID    = "10.0.0.96"
        Debut      = "10.0.0.97"
        Fin        = "10.0.0.102"
        Masque     = "255.255.255.248"
        Passerelle = "10.0.0.97"
        DNS        = "10.0.0.50"
    }
)

# ============================================================
#  FONCTION DE JOURNALISATION
# ============================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Niveau = "INFO"
    )
    $couleur = switch ($Niveau) {
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host "[$Niveau] $Message" -ForegroundColor $couleur
}

# ============================================================
#  VÉRIFICATION DES PRÉREQUIS
# ============================================================

if (-not (Get-Module -ListAvailable -Name DhcpServer)) {
    Write-Log "Le module DhcpServer n'est pas disponible. Installez le rôle DHCP." "ERROR"
    exit 1
}
Import-Module DhcpServer

Write-Host "`n=================================================="
Write-Host "   CONFIGURATION DES SCOPES DHCP"
Write-Host "==================================================`n"

# ============================================================
#  CRÉATION DE CHAQUE SCOPE
# ============================================================

foreach ($scope in $Scopes) {

    Write-Log "Traitement du scope '$($scope.Nom)' ($($scope.ScopeID))..." "INFO"

    try {
        # Vérifier si le scope existe déjà
        $existe = Get-DhcpServerv4Scope -ScopeId $scope.ScopeID -ErrorAction SilentlyContinue
        if ($existe) {
            Write-Log "Le scope '$($scope.Nom)' existe déjà. Ignoré." "WARNING"
            continue
        }

        # Création du scope
        Add-DhcpServerv4Scope `
            -Name        $scope.Nom `
            -StartRange  $scope.Debut `
            -EndRange    $scope.Fin `
            -SubnetMask  $scope.Masque `
            -State       Active

        # Configuration des options (passerelle + DNS)
        Set-DhcpServerv4OptionValue `
            -ScopeId $scope.ScopeID `
            -Router  $scope.Passerelle `
            -DnsServer $scope.DNS

        Write-Log "Scope '$($scope.Nom)' créé : $($scope.Debut) - $($scope.Fin)" "SUCCESS"
    }
    catch {
        Write-Log "Erreur sur le scope '$($scope.Nom)' : $_" "ERROR"
    }
}

# ============================================================
#  RÉCAPITULATIF
# ============================================================

Write-Host "`n=================================================="
Write-Host "   RÉCAPITULATIF DES SCOPES ACTIFS"
Write-Host "==================================================`n"

Get-DhcpServerv4Scope | Format-Table ScopeId, Name, StartRange, EndRange, State -AutoSize

Write-Log "Configuration DHCP terminée." "SUCCESS"
