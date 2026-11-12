{ ... }:
{
  # Strata runs a 125B MoE model on the Radeon 8060S through its HIP backend
  # (gfx1151 is "experimental" upstream). The engine ships its own ROCm runtime,
  # so the only thing the system has to provide is the amdgpu driver, /dev/kfd
  # (already world-readable here) and enough GTT.
  #
  # "VRAM" on Strix Halo is the GTT pool carved out of the same LPDDR5X the CPU
  # uses, and amdgpu caps it at roughly half the RAM (~62 GB of 128 GB) by
  # default. A pack with its expert cache wants more than that, so raise the
  # cap to 112 GiB (29360128 * 4 KiB pages) — the figure upstream's Strix Halo
  # guide uses on a 128 GB box. It is a ceiling, not a reservation: nothing is
  # taken from the system until the GPU asks for it.
  #
  # Upstream also boots with amd_iommu=off for the same reason. Left on here:
  # it is not needed to run, and turning the IOMMU off drops DMA protection.
  boot.kernelParams = [
    "ttm.pages_limit=29360128"
    "ttm.page_pool_size=29360128"
  ];
}
