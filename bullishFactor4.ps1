
cls

############################
#
# 
#
############################


# gravity
$bullishPct = 50.75  # 0 to 100% (decimal ok, converted result into int after used)


# dips - "buy the dip", sell the dip (puts)

# pullbacks  corrections   bear markets
# On average, a 5% decline in stock market prices has occurred 4.5 times a year over the same period.
$pullbackPct = 5 # % basis for range of random values
$pullbackFreq = 4.5 # times per year
# a decline of at least 10% occurred in 10 out of 20 years, or 50% of the time, with an average pullback of 15%
# 20% drops in the S&P 500 are still common. Expect one to two within a five-year period
$correctionPct = 15 # % calculated randomly at time of use
$correctionFreq = 0.5 # times per year


$support = 777
$resistance  = 777
$volativity  = 777
$momentum = 3 # magic number


$spyOpen = 5500

$stdDevGuidline = .15





###  DEBUG ### - move as needed  
$samples = 1
$ticksPerYear = 10000
$verboseFlag = $true
########################

$samples = 1

$verboseFlag = $false

$tradingDays = 250
#$ticksPerDay = 25200  # 60s * 60m * 7h
$ticksPerDay = 420  # 60m * 7h
$ticksPerYear = $ticksPerDay * $tradingDays  # 105,000


#################################################
#################################################
#################################################
#################################################


function myWrite( $mystring )
{

        if ( $verboseFlag ) { Write-Host $mystring }

}




function Get-StandardDeviation
    {
    
    param ( [double[]]$Numbers )
 
    $Measure = $Numbers | Measure-Object -Average
    $PopulationDeviation = 0
    ForEach ($Number in $Numbers) { $PopulationDeviation += [math]::Pow( ( $Number - $Measure.Average ), 2 ) }
    $StandardDeviation = [math]::Sqrt( $PopulationDeviation / ( $Measure.Count - 1 ) )
    return $StandardDeviation
    }
 





function UpdateChart
{
  
# handy place to put the init
$ChartSeriesPtrPtr = 0


#################################################
#################################################
for ( $samp = 1 ; $samp -le $samples ; $samp++ ) 
#################################################
#################################################
{


##########################################
#
#    ticks[] As -1,1 Random Ticks array 
#
##########################################


#
# ticks[] As -1,1 Random Ticks array 
#


#[int[]]$pool = @(1) * $bullishPct + @(-1) * ( 100 - $bullishPct )
$ticksUP = @(1) * [int]( $ticksPerYear  * $bullishPct / 100 )
$ticksDN = @(-1) * ( $ticksPerYear - $ticksUP.Length )
[int[]]$pool = $ticksUP+$ticksDN

[int[]]$randomPool = 
        Get-Random -Count $ticksPerYear -InputObject $pool
        #Get-Random -Count $ticksPerYear -InputObject ($pool * $ticksPerYear)



[int[]]$ticks = @(1) * $ticksPerYear  # seed for momentum

    

# momentum
#   comparitor will compare to random tick to see if random or streak

[int[]]$randomTick = 
        Get-Random -Count $ticksPerYear -InputObject @(0..$ticksPerYear)
        #Get-Random -Count $ticks.Length -InputObject (@(0..10) * $ticksPerYear)

        $comparitor = [int]($momentum / 10 * $ticksPerYear)




for ( $i = 1 ; $i -lt $ticks.Length ; $i++ ) 
{

        # 
         
    
        # momentum

        #if ( ( Get-Random -Minimum 0 -Maximum 10 ) -lt $momentum ) 
        if ( $randomTick[$i] -lt $comparitor ) 
        {

                $ticks[$i] = $ticks[ ( $i - 1 ) ]


        }
        else
        {
        
                #$ticks[$i] = Get-Random -InputObject $pool
                $ticks[$i] = $randomPool[$i]

        }

}

#myWrite "ticks created"
#$ticks 

##########################################
#
#     dips
#
##########################################


[int[]]$dipTicks = @(0)

#default so does not mess up pullback dates if no correction
#$correctionDay = -30
$correctionDay = 0

# see if there is a correction day
$RandomAsDecimalNumber = Get-Random -Minimum 0 -Maximum 1.0
if ( $RandomAsDecimalNumber -le $correctionFreq ) 
{ 

        $dipTicks += $correctionDay = Get-Random -Minimum 1 -Maximum $ticksPerYear 
        
}

# sprinkle in pullbacks, but not right on top of correction
for ( $i = 1 ; $i -le $pullbackFreq ; $i++ ) 
{ 
        
      #  do
       # {

                $dipTick = Get-Random -Minimum 1 -Maximum $ticksPerYear 
        
      #  }
       # until ( -not $dipTick -in ( $correctionDay - 10 )..( $correctionDay + 30 ) )


        $dipTicks += $dipTick
        
}


$dipTicks = $dipTicks | Sort-Object

#myWrite "dips created"
#$dipTicks   

##########################################
#
#     ticks with dips inserted
#
##########################################


$spyClose = $spyOpen

[double[]]$spy = @(0) * $ticks.Length
   
   
# ticks with dips inserted
                                      
for ( $j = 1 ; $j -lt $dipTicks.Length ; $j++ ) 
{
               
               
                                      
        for ( $i = $dipTicks[($j - 1)] + 1 ; $i -lt $dipTicks[$j] ; $i++ ) 
        {

                $spy[$i] = $spyClose += $ticks[$i] 

                

        }




        if ( $i -eq $correctionDay )
        {

                $Pct = Get-Random -Minimum 10 -Maximum 20
        
                $spy[($dipTicks[$j])] = $spyClose -= [int]( $Pct / 100 * $spyClose )

        }
        else
        {
        
                $lo = [int]( 0.8 * $pullbackPct )
                $hi = [int]( 1.2 * $pullbackPct )

                $Pct = Get-Random -Minimum $lo  -Maximum $hi

                $spy[($dipTicks[$j])] = $spyClose -= [int]( $Pct / 100 * $spyClose )

        }


}
   
# after last dip until end of ticks
                                      
for ( $i = $dipTicks[-1] + 1 ; $i -lt $ticks.Length ; $i++ ) 
{

        $spy[$i] = $spyClose += $ticks[$i] 

}

        

        #sleep 5

        <#

        # [int] 'Rounding half to even' 
        # [math]::Ceiling uses absolute values, so neg rounds 'up' toward 0, pos 'up' away from 0

        AwayFromZero 	1 	

        The strategy of rounding to the nearest number, and when a number is halfway between two others, it's rounded toward the nearest number that's away from zero.
        ToEven 	0 	

        The strategy of rounding to the nearest number, and when a number is halfway between two others, it's rounded toward the nearest even number.
        ToNegativeInfinity 	3 	

        The strategy of downwards-directed rounding, with the result closest to and no greater than the infinitely precise result.
        ToPositiveInfinity 	4 	

        The strategy of upwards-directed rounding, with the result closest to and no less than the infinitely precise result.
        ToZero 	2 	

        The strategy of directed rounding toward zero, with the result closest to and no greater in magnitude than the infinitely precise result.


        #>







#
# write-host 
#



write-host "Close = $spyClose"

$actual = $spyClose - $spyOpen

write-host "final Deviation = $actual"

$spyDev = [math]::Ceiling( ( Get-StandardDeviation $spy ) )

write-host "StandardDeviation = $spyDev"

# d1 = (math.log(S0/X)+(r-q+0.5*σ**2)*t)/(σ*math.sqrt(t))

# adjust per parms

# calc stdDev and adjust

# introduce externals and adjust


write-host ""



$sampleSum += ( $actual/[math]::Abs($actual) )



# Add data to the chart
$ChartSeriesPtr = $ChartSeriesNames[$ChartSeriesPtrPtr]
$ChartSeriesPtrPtr++

#$spy[ 1..- 1 ] | 
$spy[ 1..( $spy.Length - 1 ) ] | 
        ForEach-Object { [void]$chart.Series[$ChartSeriesPtr].Points.Add($_) }



} # sample


write-host "Open = $spyOpen"

$expected = $stdDevGuidline * $spyOpen

write-host "max expected StandardDeviation = $expected"

write-host "StandardDeviationGuidline = $stdDevGuidline"

write-host "out of $samples samples, net W/L $sampleSum"

# good housekeeping
$sampleSum = 0




} # UpdateChart




##########################################
#
#     chart
#
##########################################




Add-Type -AssemblyName System.Windows.Forms, System.Windows.Forms.DataVisualization

#$data = @'
#12/29/23,12/30/23,12/31/23,1/1/24,1/2/24,1/3/24
#11,16,22,28,38,55,1
#22,24,28,32,44,55,1
#'@ | ConvertFrom-Csv

$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
[void]$chart.Titles.Add('Chart Title')
$chart.Dock = [System.Windows.Forms.DockStyle]::Fill
$chart.ChartAreas.Add([System.Windows.Forms.DataVisualization.Charting.ChartArea]::new())
$chart.ChartAreas[0].AxisY.IsStartedFromZero = $false
# y axis shows lowest value to highest, not all the way down to zero


[string[]]$ChartSeriesNames = @()

for ( $i = 1 ; $i -le $samples ; $i++ )
{

        $ChartSeriesNames += "Series$($i)"

}

$ChartSeriesNames | % {

    $SeriesName = $_

    $chart.Series.Add($SeriesName) | Out-Null
    $chart.Series[$SeriesName].ChartType = 'Line'  # Area  StackedColumn
    $chart.Series[$SeriesName].IsValueShownAsLabel = $false
    # foreground color for the column values 
    $chart.Series[$SeriesName].LabelForeColor = [System.Drawing.Color]::White
    
}




##########################################
#
#     form
#
##########################################


$button = [System.Windows.Forms.button]::new()

$button.Add_Click(
{

        $ChartSeriesNames | % {  $chart.Series[$_].Points.Clear() }
        
        UpdateChart

})

# Display the chart
$form = [System.Windows.Forms.Form]::new()
$form.Size = '1280, 720'
$form.StartPosition = 'CenterScreen'
$form.Controls.Add($chart)
$form.Controls.Add($button)
$button.BringToFront()
[void]$form.ShowDialog()
$form.dispose()
