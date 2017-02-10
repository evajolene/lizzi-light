using UnityEngine;

namespace LD37
{
    public class FlatAmbientLight : MonoBehaviour
    {
        public Color color;
        public float intensity;

        void Start()
        {
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        }

        void Update()
        {
            RenderSettings.ambientLight = color;
            RenderSettings.ambientIntensity = intensity;
        }
    }
}