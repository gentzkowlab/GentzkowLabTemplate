#!/usr/bin/env julia

println("Julia script starting...")
println("This will produce some output...")
sleep(1)

println("\nOutputting multiple lines to test real-time logging:")
for i in 1:5
    println("  Line $i of output")
    sleep(0.5)
end

println("\nNow encountering an error...")
sleep(1)

# Intentional error
error("ERROR: Something went wrong in Julia!")
