Function Convert-DecimalToFraction {
    <#
        .SYNOPSIS
            Takes a decimal value and converts the value to a fraction.

        .DESCRIPTION
            Takes a decimal value and converts the value to a fraction. Displayed as
            an Improper Fraction by default. You can use -ShowMixedFraction to display 
            as a mixed fraction.

            Important
            ---------
            Repeating decimals such as .333333 can produce the correct value of 1/3 as long 
            as you keep the -ClosestDenonimator at least one length longer than the length of 
            the decimal. 

            Ex. -Decimal .33 -ClosesDecimal 1000

            A friendly warning will display stating that it isn't the most accurate value that
            will be displayed, but it can be ignored.

        .PARAMETER Decimal
            Value provided to convert into a fraction

        .PARAMETER ClosestDenominator
            The closes denominator that will be attempted to translate the decimal to 
            a fraction.

        .PARAMETER ShowMixedFraction
            Display an mixed fraction instead of an improper fraction.

        .NOTES
            Name: Convert-DecimalToFraction
            Author: Boe Prox
            Version History:
                1.0 //Boe Prox <27 Oct 2015>
                    - Initial Version

        .EXAMPLE
            Convert-DecimalToFraction -Decimal 5.5

            11/2

            Description
            -----------
            Translates 5.5 to 11/2

        .EXAMPLE
            Convert-DecimalToFraction -Decimal .333

            WARNING: Decimal <0.333> is greater of length than expected Denonimator <100>.
            Increase the size of ClosestDenonimator to <1000> to produce more accurate results.

            1/3

            Description
            -----------
            Translates .333 to 1/3 as it is the closest fraction to the given value.
            A warning shows that if you specify 1000 for -ClosestDenonimator that it will
            produce a more accurate response.

        .EXAMPLE
            Convert-DecimalToFraction -Decimal .333 -ClosestDenominator 1000

            333/1000

            Description
            -----------
            Translates .333 to 333/1000 and specifies the ClosestDenominator of 1000 to
            ensure that it is an accurate result.

        .EXAMPLE
            Convert-DecimalToFraction -Decimal 5.5 -ShowMixedFraction

            5 1/2

            Description
            -----------
            Translates 5.5 to mixed fraction: 5 1/2

        .EXAMPLE
            1.15|Convert-DecimalToFraction -AsObject

            WholeNumber Numerator Denominator
            ----------- --------- -----------
                      1         3          20

            Description
            -----------
            Converts 1.15 to a fraction and displays as an object using -AsObject.

    #>
    [cmdletbinding(
        DefaultParameterSetName = 'NonObject'
    )]
    Param(      
        [parameter(ValueFromPipeline=$True,ParameterSetName='Object')] 
        [parameter(ValueFromPipeline=$True,Position=0,ParameterSetName='NonObject')] 
        [double]$Decimal = .5,
        [parameter(ParameterSetName='Object')] 
        [parameter(ParameterSetName='NonObject')] 
        [int]$ClosestDenominator = 100,
        [parameter(ParameterSetName='NonObject')]  
        [switch]$ShowMixedFraction,
        [parameter(ParameterSetName='Object')] 
        [switch]$AsObject
    )
    Process {
        $Break = $False
        $Difference = 1
        If ($Decimal -match '^(?<WholeNumber>\d*)?(?<DecimalValue>\.\d*)?$') {
            $WholeNumber = [int]$Matches.WholeNumber
            $DecimalValue = [double]$Matches.DecimalValue
        }
        $MaxDenominatorLength = ([string]$ClosestDenominator).Length
        $DecimalLength = ([string]$Decimal).Split('.')[1].Length+1
        $LengthDiff = $MaxDenominatorLength - $DecimalLength
        If ($LengthDiff -lt 0) {
            Write-Warning @"
Decimal <$($Decimal)> is greater of length than expected Denomimator <$($ClosestDenominator)>.
Increase the size of ClosestDenomimator to <$(([string]$ClosestDenominator).PadRight($DecimalLength,'0'))> to produce more accurate results.
"@
        }        
        If ($DecimalValue -ne 0) {
            #y is Denonimator - Needs to be 2 starting out
            For ($Denominator = 2; $Denominator -le $ClosestDenominator; $Denominator++) {
                #x is Numerator - Needs to be 1 starting out
                For ($Numerator = 1; $Numerator -lt $Denominator; $Numerator++) {
                    Write-Verbose "Numerator:$($Numerator) Denominator:$($Denominator)"
                    #Try to get as close to 0 as we can get
                    $temp = [math]::Abs(($DecimalValue - ($Numerator / $Denominator)))
                    Write-Verbose "Temp: $($Temp) / Difference: $($Difference)"
                    If ($temp -lt $Difference) {                                                               
                        Write-Verbose "Fraction: $($Numerator) / $($Denominator)"
                        $Difference = $temp                         
                        $Object = [pscustomobject]@{
                            WholeNumber = $WholeNumber
                            Numerator = $Numerator
                            Denominator = $Denominator
                        }
                        If ($Difference -eq 0) {
                            $Break = $True
                        }                
                    }
                    If ($Break) {BREAK}
                }
                If ($Break) {BREAK}
            }
        } Else {
            $Object = [pscustomobject]@{
                WholeNumber = $WholeNumber
                Numerator = 0
                Denominator = 1
            }    
        }
        If ($Object) {
            If ($PSBoundParameters.ContainsKey('AsObject')) {
                $Object
            } Else {
                If ($Object.WholeNumber -gt 0) {
                    If ($PSBoundParameters.ContainsKey('ShowMixedFraction')) {
                    If ($Object.Numerator -eq 0) {
                        $Object.WholeNumber
                    } Else {
                        "{0} {1}/{2}" -f $Object.WholeNumber, $Object.Numerator, $Object.Denominator               
                    }
                    } Else {
                        $Numerator = ($Object.Denominator * $Object.WholeNumber)+$Object.Numerator
                        "{0}/{1}" -f $Numerator,$Object.Denominator                 
                    }
                } Else {
                    "{0}/{1}" -f $Object.Numerator, $Object.Denominator
                }
            }
        }
    }
}