# # Quantum Ising Phase Transition
# ### Carsten Bauer, Katharine Hyatt

# ## Introduction
#
# In this tutorial we will consider a simple quantum mechanical system of spins
# sitting on a chain. Here, *quantum mechanical*, despite its pompous sound,
# simply means that our Hamiltonian matrix will have a non-trivial (i.e.
# non-diagonal) matrix structure.
#
# We will then ask a couple of basic questions,
#
# * What is the ground state of the system?
# * What happens if we turn on a transverse magnetic field?
# * Are there any phase transitions?
#
# To get answers to the questions, we will solve the time-independent
# Schrödinger equation
#
# $$H|\psi\rangle = E |\psi\rangle$$
#
# in Julia by means of exact diagonalization of the Hamiltonian.

# ## Transverse field quantum Ising chain
# Let's start out by defining our system. The Hamiltonian is given by
# $$\mathcal{H} = -\sum_{\langle i, j \rangle} \hat{\sigma}_i^z \otimes # \hat{\sigma}_j^z - h\sum_i \hat{\sigma}_i^x$$
# Here, $\hat{\sigma}^z$ and $\hat{\sigma}^x$ are two of the three
# [Pauli matrices](https://en.wikipedia.org/wiki/Pauli_matrices), representing
# our quantum spins, $\langle i, j \rangle$ indicates that only neighboring
# spins talk to each other, and $h$ is the amplitude of the magnetic field.

σᶻ = [1 0; 0 -1] # \sigma <TAB> followed by \^z <TAB>

#-

σˣ = [0 1; 1 0]


# Labeling the eigensates of $\sigma^z$ as $|\downarrow⟩$ and # $|\uparrow⟩$,
# we interpret them as a spin pointing down or up (in $z$-direction), respectively.
#
# Clearly, since being purely off-diagonal, the effect of $\sigma^x$ on such a
# single spin is to flip it:
#
# $$\hat{\sigma}^x\left| \downarrow \right\rangle = \left| \uparrow \right\rangle$$
#
# $$\hat{\sigma}^x\left| \uparrow \right\rangle = \left| \downarrow \right\rangle$$

# The idea behind the Hamiltonian above is as follows:
#
# * The first term is diagonal in the $\sigma^z$ eigenbasis. If there is no
#   magnetic field, $h=0$, our quantum model reduces to the well-known classical
#   [Ising model](https://en.wikipedia.org/wiki/Ising_model) (diagonal = trivial
#   matrix structure → classical). In this case, we have a **finite temperature
#   phase transition** from a paramagnetic ($T>T_c$) phase, where the spins are
#   **disordered by thermal fluctuations**, to a ferromagnetic phase ($T<T_c$),
#   where they all point into the $z$ direction and, consequently, a ferromagnetic
#   ground state at $T=0$.
#
# * Since this would be boring, we want to add quantum complications to this
#   picture by making $H$ non-diagonal. To this end, we expose the quantum spins
#   to a transverse magnetic field $h$ in $x$ direction in the second term. Now,
#   since $\sigma^z$ and $\sigma^x$ do not commute (check `σˣ*σᶻ - σᶻ*σˣ`
#   yourself), there is no common eigenbasis of the first and the second term and
#   our Hamiltonian has a non-trivial matrix structure (It's quantum!). If there
#   was *only the second term* the system would, again, be trivial, as it would be
#   diagonal in the eigenbasis of $\sigma^x$: the quantum spins want to be in an
#   eigenstate of $\sigma^x$, i.e. align to the magnetic field.
#
# * We can see that if we have both terms we have a competition between the
#   spins wanting to point in the $z$ direction (first term) and at the same time
#   being disturbed by the transverse magnetic field. We say that the magnetic
#   field term adds **quantum fluctuations** to the system.
#
# Let us explore the physics of this interplay.


# ## Building the Hamiltonian matrix

# We will choose the $\sigma^z$ eigenbasis as our computation basis.
#
# To build up our Hamiltonian matrix we need to take the kronecker product
# (tensor product) of spin matrices. Fortunately, Julia has a built-in function
# for this.

kron(σᶻ,σᶻ) # this is the matrix of the tensor product σᶻᵢ⊗ σᶻⱼ (⊗ = \otimes <TAB>)

# Let's be fancy (cause we can!) and make this look a bit cooler.

⊗(x,y) = kron(x,y)

#-

σᶻ ⊗ σᶻ

# ### Explicit 4-site Hamiltonian

# Imagine our spin chain consists of four sites. Writing out identity matrices
# (which were left implicit in $H$ above) explicitly, our Hamiltonian reads
#
# $$\mathcal{H}_4 = -\hat{\sigma}_1^z \hat{\sigma}_2^z \hat{I}_3 \hat{I}_4 - \hat{I}_1 \hat{\sigma}_2^z \hat{\sigma}_3^z \hat{I}_4 - \hat{I}_1 \hat{I}_2 \hat{\sigma}_3^z \hat{\sigma}_4^z - h\left(\hat{\sigma}_1^x\hat{I}_2 \hat{I}_3\hat{I}_4 + \hat{I}_1 \hat{\sigma}_2^x \hat{I}_3\hat{I}_4 +\hat{I}_1 \hat{I}_2 \hat{\sigma}_3^x\hat{I}_4 + \hat{I}_1 \hat{I}_2 \hat{I}_3 \hat{\sigma}_4^x\right)$$
#
# (Note that we are considering *open* boundary conditions here - the spin on site 4
# doesn't interact with the one on the first site. For *periodic* boundary conditions
# we'd have to add a term $- \hat{\sigma}^z_1 \hat{I}_2 \hat{I}_3 \hat{\sigma}_4^z$.)
#
# Translating this expression to Julia is super easy. After defining the identity matrix

id = [1 0; 0 1] # identity matrix

# we can simply write

h = 1
H = - σᶻ⊗σᶻ⊗id⊗id - id⊗σᶻ⊗σᶻ⊗id - id⊗id⊗σᶻ⊗σᶻ
H -= h*(σˣ⊗id⊗id⊗id + id⊗σˣ⊗id⊗id + id⊗id⊗σˣ⊗id + id⊗id⊗id⊗σˣ)

# There it is.
#
# As nice as it is to write those tensor products explicitly, we certainly
# wouldn't want to write out all the terms for, say, 100 sites.
#
# Let's define a function that iteratively does the job for us.

function TransverseFieldIsing(;N,h)
    id = [1 0; 0 1]
    σˣ = [0 1; 1 0]
    σᶻ = [1 0; 0 -1]

    # vector of operators: [σᶻ, σᶻ, id, ...]
    first_term_ops = fill(id, N)
    first_term_ops[1] = σᶻ
    first_term_ops[2] = σᶻ

    # vector of operators: [σˣ, id, ...]
    second_term_ops = fill(id, N)
    second_term_ops[1] = σˣ

    H = zeros(Int, 2^N, 2^N)
    for i in 1:N-1
        # tensor multiply all operators
        H -= foldl(⊗, first_term_ops)
        # cyclic shift the operators
        first_term_ops = circshift(first_term_ops,1)
    end

    for i in 1:N
        H -= h*foldl(⊗, second_term_ops)
        second_term_ops = circshift(second_term_ops,1)
    end
    H
end

#-

TransverseFieldIsing(N=8, h=1)


# ### Many-particle basis
#
# Beyond a single spin, we have to think how to encode our basis states.
#
# We make the arbitrary choice:
# $0 = \text{false} = \downarrow$ and $1 = \text{true} = \uparrow$
#
# This way, our many-spin basis states have nice a binary representations and we
# can efficiently store them in a Julia `BitArray`.
#
# Example:
# $|0010\rangle = |\text{false},\text{false},\text{true},\text{false}\rangle = |\downarrow\downarrow\uparrow\downarrow\rangle$
# is a basis state of a 4-site system
#
# We construct the full basis by binary counting.

"""
Binary `BitArray` representation of the given integer `num`, padded to length `N`.
"""
bit_rep(num::Integer, N::Integer) = BitArray(parse(Bool, i) for i in string(num, base=2, pad=N))

"""
    generate_basis(N::Integer) -> basis

Generates a basis (`Vector{BitArray}`) spanning the Hilbert space of `N` spins.
"""
function generate_basis(N::Integer)
    nstates = 2^N
    basis = Vector{BitArray{1}}(undef, nstates)
    for i in 0:nstates-1
        basis[i+1] = bit_rep(i, N)
    end
    return basis
end

#-

generate_basis(4)

# ### Side remark: Iterative construction of $H$
#
# It might not be obvious that this basis is indeed the basis underlying the
# Hamiltonian matrix constructed in `TransverseFieldIsing`. To convince
# ourselves that this is indeed the case, let's calculate the matrix elements of
# our Hamiltonian, $\langle \psi_1 | H | \psi_2 \rangle$, explicitly by applying
# $H$ to our basis states and utilizing their orthonormality,
# $\langle \psi_i | \psi_j \rangle = \sigma_{i,j}$.

using LinearAlgebra

function TransverseFieldIsing_explicit(; N::Integer, h::T=0) where T<:Real
    basis = generate_basis(N)
    H = zeros(T, 2^N, 2^N)
    bonds = zip(collect(1:N-1), collect(2:N))
    for (i, bstate) in enumerate(basis)
        # diagonal part
        diag_term = 0.
        for (site_i, site_j) in bonds
            if bstate[site_i] == bstate[site_j]
                diag_term -= 1
            else
                diag_term += 1
            end
        end
        H[i, i] = diag_term

        # off diagonal part
        for site in 1:N
            new_bstate = copy(bstate)
            # flip the bit on the site (that's what σˣ does)
            new_bstate[site] = !new_bstate[site]
            # find corresponding single basis state with unity overlap (orthonormality)
            new_i = findfirst(isequal(new_bstate), basis)
            H[i, new_i] = -h
        end
    end
    return H
end

#-

TransverseFieldIsing_explicit(N=4, h=1) ≈ TransverseFieldIsing(N=4, h=1)

# ### Full exact diagonalization
#
# Alright. Let's solve the Schrödinger equation by diagonalizing $H$ for a
# system with $N=8$ and $h=1$.

basis = generate_basis(8)
H = TransverseFieldIsing(N=8, h=1)
vals, vecs = eigen(H)

# That's it. Here is our groundstate.

groundstate = vecs[:,1];

# The absolute square of this wave function is the probability of finding the system in a particular basis state.

abs2.(groundstate)

# It's instructive to look at the extremal cases $h=0$ and $h \ll 1$.

H = TransverseFieldIsing(N=8, h=0)
vals, vecs = eigen(H)
groundstate = vecs[:,1]
abs2.(groundstate)

# As we can see, for $h=0$ the system is (with probability one) in the first basis state, where all spins point in $-z$ direction.

basis[1]

# On the other hand, for $h=100$, the system occupies all basis states with
# approximately equal probability (maximal superposition) - corresponding to
# eigenstates of $\sigma^x$, i.e. alignment to the magnetic field.

H = TransverseFieldIsing(N=8, h=100)
vals, vecs = eigen(H)
groundstate = vecs[:,1]
abs2.(groundstate)


# # Are you a magnet or what?

# Let's vary $h$ and see what happens. Since we're looking at quantum magnets we
# will compute the overall magnetization, defined by
#
# $$M = \frac{1}{N}\sum_{i} \sigma^z_i$$
# where $\sigma^z_i$ is the value of the spin on site $i$ when we measure.

function magnetization(state, basis)
    M = 0.
    for (i, bstate) in enumerate(basis)
        bstate_M = 0.0
        for spin in bstate
            bstate_M += (state[i]^2 * (spin ? 1 : -1))/length(bstate)
        end
        @assert abs(bstate_M) <= 1
        M += abs(bstate_M)
    end
    return M
end

#-

magnetization(groundstate, basis)

# Now we would like to examine the effects of $h$. We will:
#
# 1. Find a variety of $h$ to look at.
# 2. For each, compute the lowest energy eigenvector (groundstate) of the
#    corresponding Hamiltonian.
# 3. For each groundstate, compute the overall magnetization $M$.
# 4. Plot $M(h)$ for a variety of system sizes, and see if anything cool happens.

using Plots
hs = 10 .^ range(-2., stop=2., length=10)
Ns = 2:2:20
p = plot()
@time for N in Ns
    M = zeros(length(hs))
    for (i,h) in enumerate(hs)
        H = TransverseFieldIsing_sparse(N=N, h=h)
        vals, vecs = eigen_sparse(H)
        groundstate = @view vecs[:,1]
        M[i] = magnetization(groundstate)
    end
    plot!(p, hs, M, xscale=:log10, marker=:circle, label="N = $N",
          xlab="h", ylab="M(h)")
    println(M)
end
p

# **This looks like a phase transition!**
#
# For small $h$, the magnetization is unity, corresponding to a ferromagnetic
# state. By increasing the magnetic field $h$ we have a competition between the
# two terms in the Hamiltonian and eventually the system becomes paramagnetic
# with $M\approx0$. Our plot suggests that this change of state happens around
# $h\sim1$, which is in good agreement with the exact solution $h=1$.
#
# It is crucial to realize, that in our calculation we are inspecting the ground
# state of the system. Since $T=0$, it is purely quantum fluctuations that drive
# the transition: a **quantum phase transition**! This is to be compared to
# increasing temperature in the classical Ising model, where it's thermal
# fluctuations that cause a classical phase transition from a ferromagnetic to a
# paramagnetic state. For this reason, the state that we observe at high
# magnetic field strengths is called a **quantum paramagnet**.


# ## Hilbert space is a big space

# So far, we have only inspected chains of length $N\leq10$. As we see in our
# plot above, there are rather strong finite-size effects on the magnetization.
# To extract a numerical estimate for the critical magnetic field strength $h_c$
# of the transition we would have to consider much larger systems until we
# observe convergence as a function of $N$. Although this is clearly beyond the
# scope of this tutorial, let us at least pave the way.
#
# Our calculation, in its current form, doesn't scale. The reason for this is
# simple, **Hilbert space is a big place!**
#
# The number of basis states, and therefore the number of dimensions, grows
# **exponentially** with system size.

plot(N -> 2^N, 1, 20, legend=false, color=:black, xlab="N", ylab="# Hilbert space dimensions")

# Our Hamiltonian matrix therefore will become huge(!) and is not going to fit
# into memory (apart from the fact that diagonalization would take forever).

using Test
@test_throws OutOfMemoryError TransverseFieldIsing(N=20, h=1)

# So, what can we do about it? The answer is, **sparsity**.
#
# Let's inspect the Hamiltonian a bit more closely.

H = TransverseFieldIsing(N=10, h=1)

# Noticably, there are a lot of zeros. How does this depend on $N$?

# Let's plot the sparsity, i.e. ratio of zero entries.

sparsity(x) = count(isequal(0), x)/length(x)

Ns = 2:12
sparsities = Float64[]
for N in Ns
    H = TransverseFieldIsing(N=N, h=1)
    push!(sparsities, sparsity(H))
end
plot(Ns, sparsities, legend=false, xlab="chain length N", ylab="Hamiltonian sparsity", marker=:circle)

# For $N\gtrsim10$ almost all entries are zero! We should get rid of those and store $H$ as a sparse matrix.


# ### Building the sparse Hamiltonian
#
# Generally, we can bring a dense matrix into a sparse matrix format using the
# function `sparse`.

using SparseArrays
H = TransverseFieldIsing(N=4,h=1)
H |> sparse

# Note that in this format, only the 80 non-zero entries are stored (rather than
# 256 elements).
#
# So, how do we have to modify our function `TransverseFieldIsing` to only keep
# track of non-zero elements during the Hamiltonian construction?
#
# It turns out it is as simple as initializing our Hamiltonian, identity, and
# Pauli matrices as sparse matrices!

function TransverseFieldIsing_sparse(;N,h)
    id = [1 0; 0 1] |> sparse
    σˣ = [0 1; 1 0] |> sparse
    σᶻ = [1 0; 0 -1] |> sparse

    first_term_ops = fill(id, N)
    first_term_ops[1] = σᶻ
    first_term_ops[2] = σᶻ

    second_term_ops = fill(id, N)
    second_term_ops[1] = σˣ

    H = spzeros(Int, 2^N, 2^N) # note the spzeros instead of zeros here
    for i in 1:N-1
        H -= foldl(⊗, first_term_ops)
        first_term_ops = circshift(first_term_ops,1)
    end

    for i in 1:N
        H -= h*foldl(⊗, second_term_ops)
        second_term_ops = circshift(second_term_ops,1)
    end
    H
end

# We should check that apart from the new type `SparseMatrixCSC` this is still the same Hamiltonian.

H = TransverseFieldIsing_sparse(N=10, h=1);
#-

H_dense = TransverseFieldIsing(N=10, h=1)
H ≈ H_dense

# Great. But is it really faster?

@time TransverseFieldIsing(N=10,h=1);
@time TransverseFieldIsing_sparse(N=10,h=1);

# It is *a lot* faster!

# Alright, let's try to go to larger $N$. While `TransverseFieldIsing` threw an
# `OutOfMemoryError` for `N=20`, our new function is more efficient:

@time H = TransverseFieldIsing_sparse(N=20,h=1)

# Note that this is matrix, formally, has **1,099,511,627,776** entries!


# ### Diagonalizing sparse matrices


# We have taken the first hurdle of constructing our large-system Hamiltonian as
# a sparse matrix. Unfortunately, if we try to diagonalize $H$, we realize that
# Julia's built-in eigensolver `eigen` doesn't support matrices.
#
# ```
# eigen(A) not supported for sparse matrices. Use for example eigs(A) from the
# Arpack package instead.
# ```


# Gladly it suggests a solution:
# [ARPACK.jl](https://github.com/JuliaLinearAlgebra/Arpack.jl). It provides a
# wrapper to the Fortran library
# [ARPACK](https://www.caam.rice.edu/software/ARPACK/) which implements
# iterative eigenvalue and singular value solvers for sparse matrices.
#
# There are also a bunch of pure Julia implementations available in
#
# * [ArnoldiMethod.jl](https://github.com/haampie/ArnoldiMethod.jl)
# * [KrylovKit.jl](https://github.com/Jutho/KrylovKit.jl)
# * [IterativeSolvers.jl](https://github.com/JuliaMath/IterativeSolvers.jl)
#
# Let us use the ArnoldiMethod.jl package.

using ArnoldiMethod

function eigen_sparse(x)
    decomp, history = partialschur(x, nev=1, which=SR()); # only solve for the ground state
    vals, vecs = partialeigen(decomp);
    return vals, vecs
end

# Solving for the ground state takes less than a minute on an i5 desktop machine.

@time vals, vecs = eigen_sparse(H)

# Voila. There we have the ground state energy and the ground state wave function for a $N=20$ chain of quantum spins!

groundstate = vecs[:,1]

# ### Magnetization once again

# To measure the magnetization, we could use our function `magnetization(state,
# basis)` from above. However, the way we wrote it above, it depends on an
# explicit list of basis states which we do not want to construct for a large
# system explicitly.
#
# Let's rewrite the function slightly such that bit representations of our basis
# states are calculated on the fly.

function magnetization(state)
    N = Int(log2(length(state)))
    M = 0.
    for i in 1:length(state)
        bstate = bit_rep(i-1,N)
        bstate_M = 0.
        for spin in bstate
            bstate_M += (state[i]^2 * (spin ? 1 : -1))/N
        end
        @assert abs(bstate_M) <= 1
        M += abs(bstate_M)
    end
    return M
end

#-

magnetization(groundstate, basis)

# We are now able to recreate our magnetization vs magnetic field strength plot
# including larger systems (takes about 3 minutes on this i5 Desktop machine).

using Plots
hs = 10 .^ range(-2., stop=2., length=10)
Ns = 2:2:20
p = plot()
@time for N in Ns
    M = zeros(length(hs))
    for (i,h) in enumerate(hs)
        H = TransverseFieldIsing_sparse(N=N, h=h)
        vals, vecs = eigen_sparse(H)
        groundstate = @view vecs[:,1]
        M[i] = magnetization(groundstate)
    end
    plot!(p, hs, M, xscale=:log10, marker=:circle, label="N = $N",
        xlab="h", ylab="M(h)")
    println(M)
end
p
