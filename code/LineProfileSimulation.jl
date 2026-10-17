using Gradus, Plots

# Unit conversions
cm2in(x) = 0.3937008x
cm2px(x) = Int(round(1.1 * cm2in(x) * 100))

# Setting plotting defaults
default(
    # Fonts
    titlefont = (12, "times"), 
    guidefont = (10, "times"), 
    legendfontfamily = "times",
    legendfontsize = 8,
    legendtitlefontfamily = "times",
    legendtitlefontsize = 8,
    tickfont = (8, "times"), 
    colorbar_titlefont = (10, "times"),
    legendtitlefontvalign = :center,
    # Grids
    gridalpha=0.2,
    minorgridalpha=0.05,
    minorgrid=true,
    minorticks=5,
    # Image
    dpi=1200,
    size=1.5*cm2px.([8,6]),
    framestyle=:box
)

## =========================================================================================
# Line profile as function of disk distance from BH
# ==========================================================================================

# Setup
m = KerrMetric(M = 1.0, a = 0.998)
d = ThinDisc(0., Inf)
x = SVector(0.0, 1E4, deg2rad(40), 0.0)

# Emissivity profile
emissivity(r) = r^-3

plt = plot(xlims=(5.5,7.5), legendtitle="Inner Radius")

for Rₘᵢₙ in [2, 10, 100, 500, 1000, 5000]

    println("R = $Rₘᵢₙ GM/c²...")

    # Getting the ISCO
    isco = Gradus.isco(m)

    # Checking if the inner radius is within the isco
    if Rₘᵢₙ < isco
        Rₘᵢₙ = isco
    end

    # Outer radius
    Rₘₐₓ = Rₘᵢₙ + 1000.

    # Calculating the lineprofile
    bins, flux = lineprofile(
        range(0,1.5,1000), emissivity, m, x, d; minrₑ=Rₘᵢₙ, maxrₑ=Rₘₐₓ, numrₑ=500, 
        verbose=false, method=TransferFunctionMethod()
    )
    
    # Plotting
    plot!(
        plt, bins*6.4, flux; 
        xlabel="Energy (keV)", ylabel="Flux (arb. units)", label="$(round(Rₘᵢₙ)) GM/c²"
    )
end

vline!([6.4]; c=:gray, ls=:dash, lw=0.8, label=nothing)

display(plt)

## =========================================================================================
# Line profile as function of a*
# ==========================================================================================

# Accretion disk and observer
d = ThinDisc(0., Inf)
x = SVector(0.0, 1E4, deg2rad(40), 0.0)
Rₘₐₓ = 50.

# Emissivity profile
emissivity(r) = r^-3

# Creating the plot
plt = plot(;xlims=[4.5,7.5])

styles = [:dashdotdot, :dash, :dashdot, :dot, :solid]

for (i, a) in enumerate([0., 0.25, 0.5, 0.75, 0.998])

    # Metric
    m = KerrMetric(M = 1.0, a = a)

    # Bounds of the accretion disk
    Rₘᵢₙ = Gradus.isco(m)

    # Rendering the lineprofile
    bins, flux = lineprofile(
        range(0,1.5,1000), emissivity, m, x, d; minrₑ=Rₘᵢₙ, maxrₑ=Rₘₐₓ, numrₑ=500, 
        verbose=false, method=TransferFunctionMethod()
    )

    # Plotting
    plot!(
        plt, bins.*6.4, flux/maximum(flux); 
        xlabel="Energy (keV)", ylabel="Flux (arb. units)", label="$a", legend=:topleft, 
        legendtitle="Spin Parameter", ls = styles[i], c=:black, lw=1.2, ylims=(0,1.1)
    )
end

vline!([6.4]; c=:gray, ls=:dash, lw=1.2, label=nothing)

display(plt)

