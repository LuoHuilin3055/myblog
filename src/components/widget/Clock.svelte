<script lang="ts">
	import { onMount } from "svelte";

	let now = $state(new Date());
	const timeFormatter = new Intl.DateTimeFormat("zh-CN", {
		timeZone: "Asia/Shanghai",
		hour: "2-digit",
		minute: "2-digit",
		second: "2-digit",
		hour12: false,
	});
	const dateFormatter = new Intl.DateTimeFormat("zh-CN", {
		timeZone: "Asia/Shanghai",
		year: "numeric",
		month: "long",
		day: "numeric",
		weekday: "long",
	});

	onMount(() => {
		const timer = window.setInterval(() => (now = new Date()), 1000);
		return () => window.clearInterval(timer);
	});
</script>

<section class="card-base p-4 text-center">
	<h2 class="font-bold text-lg text-neutral-900 dark:text-neutral-100 relative mb-3 before:w-1 before:h-4 before:rounded-md before:bg-[var(--primary)] before:absolute before:left-[-8px] before:top-[5px]">时钟</h2>
	<div class="text-3xl font-bold tracking-wider text-[var(--primary)]" aria-live="off">{timeFormatter.format(now)}</div>
	<div class="text-sm text-50 mt-2">{dateFormatter.format(now)}</div>
</section>
