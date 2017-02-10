using UnityEngine;

[RequireComponent(typeof(Camera))]
public class ShaderReplacer : MonoBehaviour
{
    public Shader replacementShader;

    void Start()
    {
        Camera camera = GetComponent<Camera>();

        if (replacementShader != null)
        {
            camera.SetReplacementShader(replacementShader, "RenderType");
        }
    }
}