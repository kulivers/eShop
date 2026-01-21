Param(
    [parameter(Mandatory=$false)][string]$acrName,
    [parameter(Mandatory=$false)][string]$gitUser,
    [parameter(Mandatory=$false)][string]$repoName="eShopOnContainers",
    [parameter(Mandatory=$false)][string]$gitBranch="dev",
    [parameter(Mandatory=$true)][string]$patToken
)

$gitContext = "https://github.com/$gitUser/$repoName"

$services = @( 
    @{ Name="eshopbasket"; Image="eshop/basket.api"; File="src/Basket.API/Dockerfile" },
    @{ Name="eshopcatalog"; Image="eshop/catalog.api"; File="src/Catalog.API/Dockerfile" },
    @{ Name="eshopidentity"; Image="eshop/identity.api"; File="src/Identity.API/Dockerfile" },
    @{ Name="eshopordering"; Image="eshop/ordering.api"; File="src/Ordering.API/Dockerfile" },
    @{ Name="eshoporderprocessor"; Image="eshop/orderprocessor"; File="src/OrderProcessor/Dockerfile" },
    @{ Name="eshoppayment"; Image="eshop/paymentprocessor"; File="src/PaymentProcessor/Dockerfile" },
    @{ Name="eshopwebapp"; Image="eshop/webapp"; File="src/WebApp/Dockerfile" }
)

$services |% {
    $bname = $_.Name
    $bimg = $_.Image
    $bfile = $_.File
    Write-Host "Setting ACR build $bname ($bimg)"    
    az acr build-task create --registry $acrName --name $bname --image ${bimg}:$gitBranch --context $gitContext --branch $gitBranch --git-access-token $patToken --file $bfile
}
