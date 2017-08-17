using UnityEngine;

namespace LizziEngine.Rendering
{
    [RequireComponent(typeof(Camera))]
    public class PostProcessRenderer : MonoBehaviour
    {
        //Camera to capture image from, to feed to the post processing shader.
        public Camera captureCamera;
        //Material to use for post processing.
        public Material postProcessMaterial;

        private int previousScreenWidth = 0, previousScreenHeight = 0;

        void Start()
        {
            captureCamera.depthTextureMode = DepthTextureMode.Depth;
        }

        void Update()
        {
            //Create new render texture when screen is resized.
            if (previousScreenHeight != Screen.height || previousScreenWidth != Screen.width)
            {
                if (captureCamera.targetTexture != null)
                {
                    captureCamera.targetTexture.Release();
                }

                captureCamera.targetTexture = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);

                previousScreenWidth = Screen.width;
                previousScreenHeight = Screen.height;
            }
        }

        void OnPostRender()
        {
            Graphics.Blit(captureCamera.targetTexture, postProcessMaterial);
        }
    }
}