// レイマーチング用レンダーフューチャー拡張
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RayRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class RaySetting
    {
        public string profilerTag = "RaymarchingRendererFeature";
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
        public LayerMask layerMask = -1;

        public Material material;
    }

    public class RayRenderPass : ScriptableRenderPass
    {
        private string profilingTag;
        private Material material;
        private FilteringSettings filteringSettings;
        private List<ShaderTagId> shaderTagIds;
        public RayRenderPass(string profilerTag, RenderPassEvent renderPassEvent, LayerMask layerMask, Material material)
        {
            this.profilingTag = profilerTag;
            this.profilingSampler = new ProfilingSampler(profilerTag);

            this.renderPassEvent = renderPassEvent;

            this.filteringSettings = new FilteringSettings(RenderQueueRange.opaque, layerMask);

            this.shaderTagIds = new List<ShaderTagId>();
            this.shaderTagIds.Add(new ShaderTagId("UniversalForward"));
            this.shaderTagIds.Add(new ShaderTagId("UniversalForwardOnly"));
            this.shaderTagIds.Add(new ShaderTagId("SRPDefaultUnlit"));

            this.material = material;

        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            ref CameraData cameraData = ref renderingData.cameraData;
            Camera camera = cameraData.camera;

            SortingCriteria sortingCriteria = renderingData.cameraData.defaultOpaqueSortFlags;
            DrawingSettings drawingSettings = CreateDrawingSettings(this.shaderTagIds, ref renderingData, sortingCriteria);

            drawingSettings.overrideMaterial = this.material;
            drawingSettings.overrideMaterialPassIndex = 0;

            // Draw
            CommandBuffer cmd = CommandBufferPool.Get(this.profilingTag);
            using (new ProfilingScope(cmd, this.profilingSampler))
            {
                context.ExecuteCommandBuffer(cmd);
                cmd.Clear();

                context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref this.filteringSettings);
            }
            context.ExecuteCommandBuffer(cmd);

            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }
    }

    public RaySetting raySetting = new RaySetting();
    private RayRenderPass rayRenderPass;

    public override void Create()
    {
        this.rayRenderPass = new RayRenderPass(raySetting.profilerTag, raySetting.renderPassEvent, raySetting.layerMask, raySetting.material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(rayRenderPass);
    }
}
