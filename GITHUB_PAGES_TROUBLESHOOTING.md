# GitHub Pages Deployment Troubleshooting

## Common Issues and Solutions

### 1. **GitHub Pages Not Enabled**
   - Go to your repository on GitHub
   - Click **Settings** → **Pages**
   - Under "Source", select **"GitHub Actions"** (not "Deploy from a branch")
   - Save the settings

### 2. **Workflow Not Running**
   - Go to **Actions** tab in your repository
   - Check if the workflow is running after you push
   - If it's not running, check:
     - Is the workflow file in `.github/workflows/ci.yml`?
     - Is it committed to the `main` branch?
     - Are GitHub Actions enabled in repository settings?

### 3. **Workflow Failing**
   - Check the **Actions** tab for error messages
   - Common issues:
     - Missing dependencies in `pip install`
     - Build errors (check mkdocs build output)
     - Permission issues

### 4. **Changes Not Showing**
   - GitHub Pages can take a few minutes to deploy
   - Clear your browser cache (Ctrl+Shift+R)
   - Check the deployment status in **Settings** → **Pages**
   - Verify the site URL matches your `site_url` in `mkdocs.yml`

### 5. **Force a New Deployment**
   If you need to trigger a new deployment:
   ```bash
   git commit --allow-empty -m "Trigger GitHub Pages deployment"
   git push origin main
   ```

## Current Workflow Configuration

Your workflow uses the modern GitHub Pages deployment method:
- Uses `actions/deploy-pages@v4`
- Requires GitHub Pages to be configured with "GitHub Actions" as the source
- Deploys from the `./site` directory after `mkdocs build`

## Verification Steps

1. ✅ Check repository Settings → Pages → Source = "GitHub Actions"
2. ✅ Check Actions tab for workflow runs
3. ✅ Verify workflow completes successfully (green checkmark)
4. ✅ Check deployment status in Settings → Pages
5. ✅ Visit your site URL: https://MarcelloDe.github.io/mkdocs/
