const express = require('express');
const compression = require('compression');
const path = require('path');
const app = express();

const PORT = process.env.PORT || 3000;

// Enable gzip compression for better performance
app.use(compression());

// Serve static files with caching
app.use(express.static(__dirname, {
    setHeaders: (res, filePath, stat) => {
        if (filePath.endsWith('index.html')) {
            // Never cache index.html so updates are immediate
            res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
        } else {
            // Cache other static assets for a long time (1 year)
            res.setHeader('Cache-Control', 'public, max-age=31536000');
        }
    }
}));

// SPA fallback: serve index.html for any unknown routes
app.get('*', (req, res) => {
    res.sendFile(path.resolve(__dirname, 'index.html'));
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

