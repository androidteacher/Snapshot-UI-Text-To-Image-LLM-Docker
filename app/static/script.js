/**
 * Snapshot-UI — Frontend Logic
 * Handles prompt submission, image display, and download.
 */

(function () {
    "use strict";

    // DOM refs
    const form         = document.getElementById("promptForm");
    const input        = document.getElementById("promptInput");
    const generateBtn  = document.getElementById("generateBtn");
    const placeholder  = document.getElementById("placeholder");
    const imageContainer = document.getElementById("imageContainer");
    const generatedImage = document.getElementById("generatedImage");
    const imageMeta    = document.getElementById("imageMeta");
    const loadingState = document.getElementById("loadingState");
    const loadingPrompt= document.getElementById("loadingPrompt");
    const errorState   = document.getElementById("errorState");
    const errorText    = document.getElementById("errorText");
    const downloadBtn  = document.getElementById("downloadBtn");
    const statusBadge  = document.getElementById("statusBadge");

    let currentImageData = null;
    let currentPrompt    = "";

    // ------------------------------------------------------------------ //
    // Health check
    // ------------------------------------------------------------------ //
    async function checkHealth() {
        try {
            const res = await fetch("/health");
            const data = await res.json();
            if (data.status === "ok" && data.model_loaded) {
                statusBadge.className = "status-badge online";
                statusBadge.querySelector(".status-text").textContent = "Model Ready";
            } else {
                statusBadge.className = "status-badge";
                statusBadge.querySelector(".status-text").textContent = "Loading Model...";
                // Retry until model is loaded
                setTimeout(checkHealth, 3000);
            }
        } catch {
            statusBadge.className = "status-badge error";
            statusBadge.querySelector(".status-text").textContent = "Offline";
            setTimeout(checkHealth, 5000);
        }
    }

    // ------------------------------------------------------------------ //
    // UI State helpers
    // ------------------------------------------------------------------ //
    function showView(viewId) {
        [placeholder, imageContainer, loadingState, errorState].forEach(el => {
            el.style.display = "none";
        });
        document.getElementById(viewId).style.display = "flex";
    }

    function setInputEnabled(enabled) {
        input.disabled = !enabled;
        generateBtn.disabled = !enabled;
    }

    // ------------------------------------------------------------------ //
    // Generate
    // ------------------------------------------------------------------ //
    async function generate(prompt) {
        showView("loadingState");
        loadingPrompt.textContent = `"${prompt}"`;
        setInputEnabled(false);
        downloadBtn.style.display = "none";

        try {
            const res = await fetch("/generate", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ prompt }),
            });

            if (!res.ok) {
                const err = await res.json().catch(() => ({ detail: "Unknown error" }));
                throw new Error(err.detail || `HTTP ${res.status}`);
            }

            const data = await res.json();
            currentImageData = data.image;
            currentPrompt    = prompt;

            // Show image
            generatedImage.src = `data:image/png;base64,${data.image}`;
            imageMeta.textContent = `Generated in ${data.elapsed}s · 512×512`;
            showView("imageContainer");
            downloadBtn.style.display = "flex";

        } catch (err) {
            errorText.textContent = err.message;
            showView("errorState");
        } finally {
            setInputEnabled(true);
            input.value = "";
            input.focus();
        }
    }

    // ------------------------------------------------------------------ //
    // Download
    // ------------------------------------------------------------------ //
    function downloadImage() {
        if (!currentImageData) return;

        const link = document.createElement("a");
        link.href = `data:image/png;base64,${currentImageData}`;

        // Sanitize prompt for filename
        const safeName = currentPrompt
            .replace(/[^a-zA-Z0-9 ]/g, "")
            .replace(/\s+/g, "_")
            .substring(0, 40)
            || "generated";
        link.download = `snapshot_${safeName}.png`;

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    // ------------------------------------------------------------------ //
    // Events
    // ------------------------------------------------------------------ //
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const prompt = input.value.trim();
        if (prompt) generate(prompt);
    });

    downloadBtn.addEventListener("click", downloadImage);

    // Keyboard shortcut: Ctrl+Enter (or Cmd+Enter) to generate
    input.addEventListener("keydown", (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === "Enter") {
            e.preventDefault();
            form.dispatchEvent(new Event("submit"));
        }
    });

    // ------------------------------------------------------------------ //
    // Init
    // ------------------------------------------------------------------ //
    checkHealth();
    input.focus();
})();
