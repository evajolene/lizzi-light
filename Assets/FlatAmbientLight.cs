using UnityEngine;

namespace LizziEngine.Rendering
{
    public class FlatAmbientLight : MonoBehaviour
    {
        public Color color;

        void Start()
        {
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        }

        void Update()
        {
            RenderSettings.ambientLight = color;
        }
    }
}