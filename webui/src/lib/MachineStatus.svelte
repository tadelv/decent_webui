<script>
	import { onMount } from 'svelte';
	import TemperatureWidget from './TemperatureWidget.svelte';
	import MachineState from './MachineState.svelte';

	let status = 'off';
	let machine_data;
	async function fetchStatus() {
		let response = await fetch('http://localhost:8888/api/status/details');
		let data = await response.json();
		status = data.state;
		machine_data = data;
		console.log(data);
		console.log(machine_data);
	}
	let promise;
	onMount(() => {
		promise = fetchStatus();
	});
</script>

{#await promise}
	<p>loading...</p>
{:then}
	<p>Machine state: {status}</p>
	{#if status == 'Idle'}
		<p>Machine data: {JSON.stringify(machine_data)}</p>
		<TemperatureWidget
			head={machine_data.head_temperature}
			mix={machine_data.mix_temperature}
			steam={machine_data.steam_heater_temperature}
		/>
	{/if}
{:catch error}
	<p>{error.message}</p>
{/await}
<MachineState />
